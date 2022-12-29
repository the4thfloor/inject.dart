// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:build/build.dart';
import 'package:collection/collection.dart';

import '../analyzer/utils.dart';
import '../analyzer/visitors.dart';
import '../context.dart';
import '../source/symbol_path.dart';
import '../summary.dart';
import 'abstract_builder.dart';

/// Extracts metadata about modules and components from Dart libraries.
class InjectSummaryBuilder extends AbstractInjectBuilder {
  /// Constructor.
  const InjectSummaryBuilder();

  @override
  Future<String> buildOutput(BuildStep buildStep) {
    return runInContext<String>(buildStep, () => _buildInContext(buildStep));
  }

  Future<String> _buildInContext(BuildStep buildStep) async {
    log.info('Generating DI summary for ${buildStep.inputId}');
    final resolver = buildStep.resolver;
    log.info('After resolve');
    LibrarySummary summary;
    if (await resolver.isLibrary(buildStep.inputId)) {
      final lib = await buildStep.inputLibrary;
      final components = <ComponentSummary>[];
      final modules = <ModuleSummary>[];
      final injectables = <InjectableSummary>[];
      _SummaryBuilderVisitor(components, modules, injectables)
          .visitLibrary(lib);
      if (components.isEmpty && modules.isEmpty && injectables.isEmpty) {
        // We are going to be outputting an empty file, which is not ideal.
        // Users should take steps to make sure summary building steps only
        // run on files that will actually be used by inject, and not on
        // entire libraries - this will cause unnecessary latency in build
        // time as we resolve Dart ASTs that are unrelated to dependency
        // injection.
        builderContext.log.info(
            lib,
            'no @module, @component or @provide annotated classes '
            'found in library');
      }
      summary = LibrarySummary(
        SymbolPath.toAssetUri(lib.source.uri),
        components: components,
        modules: modules,
        injectables: injectables,
      );
    } else {
      final contents = await buildStep.readAsString(buildStep.inputId);
      if (contents.contains(RegExp(r'part\s+of'))) {
        builderContext.rawLogger.info(
          'Skipping ${buildStep.inputId} because it is a part file.',
        );
      } else {
        builderContext.rawLogger.severe(
          'Failed to analyze ${buildStep.inputId}. Please check that the '
          'file is a valid Dart library.',
        );
      }
      summary = LibrarySummary(
        Uri(
          scheme: 'asset',
          path: '${buildStep.inputId.package}/${buildStep.inputId.path}',
        ),
      );
    }
    return _librarySummaryToJson(summary);
  }

  @override
  String get inputExtension => 'dart';

  @override
  String get outputExtension => 'inject.summary';
}

class _SummaryBuilderVisitor extends InjectLibraryVisitor {
  final List<ComponentSummary> _components;
  final List<ModuleSummary> _modules;
  final List<InjectableSummary> _injectables;

  _SummaryBuilderVisitor(this._components, this._modules, this._injectables);

  @override
  void visitInjectable(ClassElement clazz, bool singleton) {
    final classIsAnnotated = hasProvideAnnotation(clazz);
    final annotatedConstructors =
        clazz.constructors.where(hasProvideAnnotation).toList();

    if (classIsAnnotated && annotatedConstructors.isNotEmpty) {
      builderContext.log.severe(
        clazz,
        'has @provide annotation on both the class and on one of the '
        'constructors or factories. Please annotate one or the other, '
        'but not both.',
      );
    }

    if (classIsAnnotated && clazz.constructors.length > 1) {
      builderContext.log.severe(
        clazz,
        'has more than one constructor. Please annotate one of the '
        'constructors instead of the class.',
      );
    }

    if (annotatedConstructors.length > 1) {
      builderContext.log.severe(
        clazz,
        'no more than one constructor may be annotated with @provide.',
      );
    }

    ProviderSummary? constructorSummary;
    if (annotatedConstructors.length == 1) {
      // Use the explicitly annotated constructor.
      constructorSummary = _createConstructorProviderSummary(
        annotatedConstructors.single,
        singleton,
      );
    } else if (classIsAnnotated) {
      if (clazz.constructors.length <= 1) {
        // This is the case of a default or an only constructor.
        constructorSummary = _createConstructorProviderSummary(
          clazz.constructors.single,
          singleton,
        );
      }
    }

    if (constructorSummary != null) {
      _injectables
          .add(InjectableSummary(getSymbolPath(clazz), constructorSummary));
    }
  }

  @override
  void visitComponent(ClassElement clazz, List<SymbolPath> modules) {
    final visitor = _ProviderSummaryVisitor(true)..visitClass(clazz);
    if (visitor._providers.isEmpty) {
      builderContext.log
          .severe(clazz, 'component class must declare at least one provider');
    }
    final providers = visitor._providers.where((ps) {
      if (ps.isAsynchronous) {
        builderContext.log.severe(
          clazz,
          'component class must not declare asynchronous providers',
        );
        return false;
      }
      return true;
    }).toList();
    final summary = ComponentSummary(getSymbolPath(clazz), modules, providers);
    _components.add(summary);
  }

  @override
  void visitModule(ClassElement clazz) {
    final visitor = _ProviderSummaryVisitor(false)..visitClass(clazz);
    final providers = visitor._providers.where((ps) {
      if (ps.kind == ProviderKind.getter) {
        builderContext.log.severe(
          clazz,
          'module class must not declare providers as getters, '
          'but only as methods.',
        );
        return false;
      }
      return true;
    }).toList();
    if (providers.isEmpty) {
      builderContext.log
          .warning(clazz, 'module class must declare at least one provider');
      return;
    }
    final summary = ModuleSummary(getSymbolPath(clazz), providers);
    _modules.add(summary);
  }
}

class _ProviderSummaryVisitor extends InjectClassVisitor {
  final List<ProviderSummary> _providers = <ProviderSummary>[];

  _ProviderSummaryVisitor(bool isForComponent) : super(isForComponent);

  @override
  void visitProvideMethod(
    MethodElement method,
    bool singleton,
    bool asynchronous, {
    SymbolPath? qualifier,
  }) {
    if (isForComponent && !method.isAbstract) {
      builderContext.log.severe(
        method,
        'providers declared on component class must be abstract.',
      );
      return;
    }
    if (asynchronous && !method.returnType.isDartAsyncFuture) {
      builderContext.log.severe(
        method,
        'asynchronous provider must return a Future.',
      );
      return;
    }

    final returnType = asynchronous
        ? (method.returnType as ParameterizedType).typeArguments.single
        : method.returnType;

    if (!_checkReturnType(method, returnType.element!)) {
      return;
    }

    if (!isForComponent && returnType is FunctionType) {
      builderContext.log.severe(
          returnType.element,
          'Modules are not allowed to provide a function type () -> Type. '
          'The inject library prohibits this to avoid confusion '
          'with injecting providers of injectable types. '
          'Your provider method will not be used.');
      return;
    }

    final summary = ProviderSummary(
      getInjectedType(returnType, qualifier: qualifier),
      method.name,
      ProviderKind.method,
      singleton: singleton,
      asynchronous: asynchronous,
      dependencies: method.parameters
          .map((p) {
            if (isForComponent) {
              builderContext.log
                  .severe(p, 'component methods cannot have parameters');
              return null;
            } else if (p.isNamed) {
              builderContext.log
                  .severe(p, 'named provider parameters are unsupported');
              return null;
            }

            if (p.type.isDynamic) {
              builderContext.log.severe(
                  p.enclosingElement,
                  'Parameter named `${p.name}` resolved to dynamic. This can '
                  'happen when the return type is not specified, when it is '
                  'specified as `dynamic`, or when the return type failed to '
                  'resolve to a proper type due to a bad import or a typo. Do '
                  'make sure that there are no analyzer warnings in your '
                  'code.');
              return null;
            }
            return getInjectedType(
              p.type,
              qualifier: hasQualifier(p) ? extractQualifier(p) : null,
            );
          })
          .whereNotNull()
          .toList(),
    );
    _providers.add(summary);
  }

  @override
  void visitProvideGetter(FieldElement field, bool singleton) {
    if (!_checkReturnType(field.getter!, field.getter!.returnType.element!)) {
      return;
    }
    final returnType = field.getter!.returnType;
    final summary = ProviderSummary(
      getInjectedType(returnType),
      field.name,
      ProviderKind.getter,
      singleton: singleton,
      dependencies: const [],
    );
    _providers.add(summary);
  }

  bool _checkReturnType(
    ExecutableElement executableElement,
    Element returnTypeElement,
  ) {
    if (returnTypeElement.kind == ElementKind.DYNAMIC ||
        returnTypeElement is TypeDefiningElement &&
            returnTypeElement.kind == ElementKind.DYNAMIC) {
      builderContext.log.severe(
        executableElement,
        'provider return type resolved to dynamic. This can happen when the '
        'return type is not specified, when it is specified as `dynamic`, or '
        'when the return type failed to resolve to a proper type due to a '
        'bad import or a typo. Do make sure that there are no analyzer '
        'warnings in your code.',
      );
      return false;
    }
    return true;
  }
}

ProviderSummary _createConstructorProviderSummary(
  ConstructorElement element,
  bool isSingleton,
) {
  final returnType = element.enclosingElement.thisType;
  return ProviderSummary(
    getInjectedType(returnType),
    element.name,
    ProviderKind.constructor,
    singleton: isSingleton,
    dependencies: element.parameters
        .map((p) {
          SymbolPath? qualifier;
          if (hasQualifier(p)) {
            qualifier = extractQualifier(p);
          } else if (p.isInitializingFormal) {
            // In the example of:
            //
            // @someQualifier
            // final String _some;
            //
            // Clazz(this._some);
            //
            // Extract @someQualifier as the qualifier.
            final clazz = element.enclosingElement;
            final formal = clazz.getField(p.name)!;
            if (hasQualifier(formal)) {
              qualifier = extractQualifier(formal);
            }
          }

          if (p.type.isDynamic) {
            builderContext.log.severe(
              p,
              'a constructor argument type resolved to dynamic. This can '
              'happen when the return type is not specified, when it is '
              'specified as `dynamic`, or when the return type failed '
              'to resolve to a proper type due to a bad import or a '
              'typo. Do make sure that there are no analyzer warnings '
              'in your code.',
            );
            return null;
          }

          if (p.isNamed) {
            builderContext.log
                .severe(p, 'named constructor parameters are unsupported');
            return null;
          }

          return getInjectedType(p.type, qualifier: qualifier);
        })
        .whereNotNull()
        .toList(),
  );
}

String _librarySummaryToJson(LibrarySummary library) {
  return const JsonEncoder.withIndent('  ').convert(library);
}
