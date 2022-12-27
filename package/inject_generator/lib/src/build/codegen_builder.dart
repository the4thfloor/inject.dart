// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:dart_style/dart_style.dart';

import '../context.dart';
import '../graph.dart';
import '../source/injected_type.dart';
import '../source/lookup_key.dart';
import '../source/symbol_path.dart';
import '../summary.dart';
import 'abstract_builder.dart';

/// Generates code for a dependency injection-aware library.
class InjectCodegenBuilder extends AbstractInjectBuilder {
  final bool _useScoping;

  const InjectCodegenBuilder({bool useScoping = true})
      : _useScoping = useScoping;

  @override
  String get inputExtension => 'summary';

  @override
  String get outputExtension => 'dart';

  @override
  Future<String> buildOutput(BuildStep buildStep) {
    return runInContext<String>(buildStep, () => _buildInContext(buildStep));
  }

  Future<String> _buildInContext(BuildStep buildStep) async {
    // We initially read in our <name>.inject.summary JSON blob, parse it, and
    // use it to generate a "{className}$Injector" Dart class for each @injector
    // annotation that was processed and put in the summary.
    final summary = await buildStep
        .readAsString(buildStep.inputId)
        .then(jsonDecode)
        .then((json) => LibrarySummary.parseJson(json));

    if (summary.injectors.isEmpty) {
      return '';
    }

    // If we require additional summaries (modules, etc) in other libraries we
    // setup an asset reader that knows how to get the dependencies we need.
    final reader = _AssetSummaryReader(buildStep);

    // This is the library that will be output when done.
    final target = LibraryBuilder();

    for (final injector in summary.injectors) {
      // Based on this summary, we might need knowledge of other summaries for
      // modules we include, providers we want to generate, etc. Pre-process the
      // summary and get back an object graph.
      final resolver = InjectorGraphResolver(reader, injector);
      final graph = await resolver.resolve();

      // Add to the file.
      target.body.add(
        _InjectorBuilder(summary.assetUri, injector, graph).build(),
      );
    }

    final emitter = _useScoping
        ? DartEmitter.scoped(useNullSafetySyntax: true)
        : DartEmitter(useNullSafetySyntax: true);
    return DartFormatter().format(
      target.build().accept(emitter).toString(),
    );
  }
}

/// A simple implementation wrapping a [BuildStep].
class _AssetSummaryReader implements SummaryReader {
  final BuildStep _buildStep;

  const _AssetSummaryReader(this._buildStep);

  @override
  Future<LibrarySummary> read(String package, String path) {
    return _buildStep
        .readAsString(AssetId(package, path))
        .then(jsonDecode)
        .then((json) => LibrarySummary.parseJson(json));
  }
}

class _Variable {
  final String name;
  final Reference type;

  const _Variable({
    required this.name,
    required this.type,
  });
}

/// Generates code for one injector class.
class _InjectorBuilder {
  /// The URI of the library that defines the injector.
  ///
  /// Import URIs should be calculated relative to this URI. Because the
  /// generated `.inject.dart` file sits in the same directory as the source
  /// `.dart` file, the relative URIs are compatible between the two.
  final Uri libraryUri;

  final InjectorSummary summary;
  final InjectorGraph graph;

  /// The name of the concrete class that implements the injector interface.
  final String concreteName;

  /// The type of the original injector interface.
  final Reference injectorType;

  /// The generated type of the implementing injector class.
  final Reference concreteInjectorType;

  /// Dependencies instantiated eagerly during initialization of the injector.
  final BlockBuilder preInstantiations = BlockBuilder();

  /// Dependencies already visited during graph traversal.
  final Set<LookupKey> _visitedPreInstantiations = <LookupKey>{};

  final Map<LookupKey, MethodBuilder> creatorMethods =
      <LookupKey, MethodBuilder>{};
  final Map<SymbolPath, _Variable> moduleVariables = <SymbolPath, _Variable>{};

  /// Provider methods on the generated injector class.
  final List<MethodBuilder> injectorProviders = <MethodBuilder>[];

  /// Fields (modules, singletons) on the injector class.
  final List<FieldBuilder> fields = <FieldBuilder>[];

  /// The constructor of the generated injector class.
  ///
  /// We create a single constructor that will be used by the source class'
  /// factory constructor. It has a single parameter for _each_ module that
  /// the injector uses.
  final ConstructorBuilder constructor = ConstructorBuilder()..name = '_';

  /// Used to distinguish the names of unused modules.
  int _unusedCounter = 1;

  factory _InjectorBuilder(
    Uri libraryUri,
    InjectorSummary summary,
    InjectorGraph graph,
  ) {
    final concreteName = '${summary.clazz.symbol}\$Injector';
    final injectorType = refer(
      summary.clazz.symbol,
      summary.clazz.toDartUri(relativeTo: libraryUri).toString(),
    );
    final concreteInjectorType = refer(concreteName);
    return _InjectorBuilder._(
      libraryUri,
      summary,
      graph,
      concreteName,
      injectorType,
      concreteInjectorType,
    );
  }

  _InjectorBuilder._(
    this.libraryUri,
    this.summary,
    this.graph,
    this.concreteName,
    this.injectorType,
    this.concreteInjectorType,
  );

  /// Builds a concrete implementation of the given injector interface.
  Class build() {
    _generateInjectorProviders();
    return Class(
      (b) => b
        ..name = concreteName
        ..implements.add(injectorType)
        ..fields.addAll(fields.map((b) => b.build()))
        ..constructors.add(constructor.build())
        ..methods.add(_generateInjectorCreatorMethod())
        ..methods.addAll(creatorMethods.values.map((b) => b.build()))
        ..methods.addAll(injectorProviders.map((b) => b.build())),
    );
  }

  Method _generateInjectorCreatorMethod() {
    final returnType = TypeReference(
      (b) => b
        ..symbol = 'Future'
        ..url = 'dart:async'
        ..types.add(injectorType),
    );
    final injectorCreator = MethodBuilder()
      ..name = 'create'
      ..returns = returnType
      ..static = true
      ..modifier = MethodModifier.async;
    for (final moduleSymbol in graph.includeModules) {
      if (moduleVariables.containsKey(moduleSymbol)) {
        final moduleVariable = moduleVariables[moduleSymbol]!;
        injectorCreator.requiredParameters.add(
          Parameter(
            (b) => b
              ..name = moduleVariable.name
              ..type = moduleVariable.type,
          ),
        );
      } else {
        final moduleType = _reference(moduleSymbol);
        builderContext.rawLogger.warning(
          'Unused module in ${summary.clazz.symbol}: ${moduleSymbol.symbol}',
        );
        injectorCreator.requiredParameters.add(
          Parameter(
            (b) => b
              ..name = '_' * _unusedCounter++
              ..type = moduleType,
          ),
        );
      }
    }
    final initExpression = concreteInjectorType.newInstanceNamed(
      '_',
      moduleVariables.values.map((v) => refer(v.name).expression).toList(),
    );
    injectorCreator.body = Block(
      (b) => b.statements
        ..add(declareFinal('injector').assign(initExpression).statement)
        ..add(preInstantiations.build())
        ..add(refer('injector').returned.statement),
    );
    return injectorCreator.build();
  }

  void _generateInjectorProviders() {
    // Generate injector providers.
    for (final provider in graph.providers) {
      final returnType = _referenceForType(provider.injectedType);
      final method = MethodBuilder()
        ..name = provider.methodName
        ..returns = returnType
        ..type = provider.isGetter ? MethodType.getter : null
        ..lambda = true
        ..body = _invokeCreateMethod(
          dependency: provider.injectedType,
          scope: 'this',
          requestedBy: summary.clazz,
        ).code
        ..annotations.add(refer('override'));
      injectorProviders.add(method);
    }
  }

  void _generateModuleField(SymbolPath m) {
    if (moduleVariables.containsKey(m)) {
      // Already generated.
      return;
    }
    final paramName = _decapitalize(m.symbol);
    final fieldName = '_$paramName';
    final moduleType = _reference(m);
    fields.add(
      FieldBuilder()
        ..name = fieldName
        ..modifier = FieldModifier.final$
        ..type = moduleType,
    );
    constructor.requiredParameters.add(
      Parameter(
        (b) => b
          ..name = fieldName
          ..toThis = true,
      ),
    );
    moduleVariables[m] = _Variable(name: paramName, type: moduleType);
  }

  // Returns a _create{{Type}}() method invocation, creating the needed
  // _create method if necessary; OR, returns a method reference if [dependency]
  // is a provider.
  Expression _invokeCreateMethod({
    required InjectedType dependency,
    required String scope,
    required SymbolPath requestedBy,
  }) {
    if (!graph.mergedDependencies.containsKey(dependency.lookupKey)) {
      logUnresolvedDependency(
        injectorSummary: summary,
        dependency: dependency.lookupKey.root,
        requestedBy: requestedBy,
      );
      return literalNull;
    }
    _generateCreateMethod(graph.mergedDependencies[dependency.lookupKey]!);
    final creatorMethod = _creatorMethodReference(dependency.lookupKey, scope);
    return dependency.isProvider ? creatorMethod : creatorMethod.call(const []);
  }

  // TODO(alanrussian): Consider refactoring this so that we add an incrementing
  // number on each unique name to prevent collisions.
  static String _lookupKeyName(LookupKey key) {
    final qualifier = key.qualifier
        .transform((symbolPath) => _camelCase(symbolPath.symbol))
        .or('');
    final root = _camelCase(key.root.symbol);
    return '$qualifier$root';
  }

  static String _creatorMethodName(LookupKey key) {
    return '_create${_lookupKeyName(key)}';
  }

  static String _camelCase(String string) =>
      string.substring(0, 1).toUpperCase() + string.substring(1);

  static Reference _creatorMethodReference(LookupKey key, String scope) {
    var prefix = '';
    if (scope != 'this') {
      prefix = '$scope.';
    }
    return refer('$prefix${_creatorMethodName(key)}');
  }

  void _generateCreateMethod(ResolvedDependency dependency) {
    final key = dependency.lookupKey;
    if (creatorMethods.containsKey(key)) {
      // Already generated.
      return;
    }

    // Reserve the slot to prevent cycles.
    // TODO
    // creatorMethods[key] = null;

    if (dependency is DependencyProvidedByModule) {
      _generateModuleField(dependency.moduleClass);
    }

    final method = MethodBuilder()
      ..name = _creatorMethodName(key)
      ..returns = _referenceForKey(key)
      ..body = _createDependency(dependency).code
      ..lambda = true;
    creatorMethods[key] = method;
  }

  // Returns an expression that will return an instance of a dependency.
  Expression _createDependency(ResolvedDependency dependency) {
    final lookupKeyName = _lookupKeyName(dependency.lookupKey);
    final dependencyExpression = dependency.isAsynchronous
        ? refer('_${_decapitalize(lookupKeyName)}')
        : _createDependencyInstantiatingExpression(dependency, 'this');
    if (dependency.isAsynchronous) {
      _preInstantiateDependency(dependency);
      return dependencyExpression;
    } else if (dependency.isSingleton) {
      // Create a field in the injector to cache the dependency.
      final fieldName = '_singleton$lookupKeyName';
      fields.add(
        FieldBuilder()
          ..name = fieldName
          ..type = _referenceForKey(dependency.lookupKey, isNullable: true),
      );

      // The body is 'cacheField ??= dependencyExpression'.
      return refer(fieldName).assignNullAware(dependencyExpression);
    } else {
      return dependencyExpression;
    }
  }

  Expression _createDependencyInstantiatingExpression(
    ResolvedDependency dependency,
    String scope,
  ) {
    var prefix = '';
    if (scope != 'this') {
      prefix = '$scope.';
    }
    Expression dependencyExpression;
    if (dependency is DependencyProvidedByModule) {
      final callExpression =
          '${prefix}_${_decapitalize(dependency.moduleClass.symbol)}.${dependency.methodName}';
      dependencyExpression = refer(callExpression).call(
        dependency.dependencies
            .map(
              (d) => _invokeCreateMethod(
                dependency: d,
                scope: scope,
                requestedBy: dependency.moduleClass,
              ),
            )
            .toList(),
      );
    } else if (dependency is DependencyProvidedByInjectable) {
      final type = refer(
        dependency.summary.clazz.symbol,
        dependency.summary.clazz.toDartUri(relativeTo: libraryUri).toString(),
      );
      final constructorName = dependency.summary.constructor.name;
      if (constructorName.isEmpty) {
        dependencyExpression = type.newInstance(
          dependency.dependencies
              .map(
                (d) => _invokeCreateMethod(
                  dependency: d,
                  scope: scope,
                  requestedBy: dependency.summary.clazz,
                ),
              )
              .toList(),
        );
      } else {
        dependencyExpression = type.newInstanceNamed(
          constructorName,
          dependency.dependencies
              .map(
                (d) => _invokeCreateMethod(
                  dependency: d,
                  scope: scope,
                  requestedBy: dependency.summary.clazz,
                ),
              )
              .toList(),
        );
      }
    } else {
      throw StateError(
        'Unrecognized dependency type: ${dependency.runtimeType}',
      );
    }
    return dependencyExpression;
  }

  void _preInstantiateDependency(ResolvedDependency dep) {
    if (_visitedPreInstantiations.contains(dep.lookupKey)) {
      return;
    }
    _visitedPreInstantiations.add(dep.lookupKey);
    for (final depDep in dep.dependencies) {
      _preInstantiateDependency(graph.mergedDependencies[depDep.lookupKey]!);
    }

    // Then instantiate.
    if (dep.isAsynchronous) {
      final fieldName = '_${_decapitalize(_lookupKeyName(dep.lookupKey))}';
      fields.add(
        FieldBuilder()
          ..name = fieldName
          ..type = _referenceForKey(dep.lookupKey)
          ..late = true,
      );
      final dependencyExpression = _createDependencyInstantiatingExpression(
        dep,
        'injector',
      ).awaited;
      preInstantiations.statements.add(
        refer('injector.$fieldName').assign(dependencyExpression).statement,
      );
    }
  }

  Reference _referenceForType(InjectedType injectedType) {
    final keyReference = _referenceForKey(injectedType.lookupKey);
    if (injectedType.isProvider) {
      return FunctionType(
        (functionType) => functionType..returnType = keyReference,
      );
    }
    return keyReference;
  }

  Reference _referenceForKey(LookupKey key, {bool isNullable = false}) =>
      _reference(key.root, isNullable: isNullable);

  Reference _reference(SymbolPath symbolPath, {bool isNullable = false}) =>
      TypeReference(
        (b) => b
          ..symbol = symbolPath.symbol
          ..url = symbolPath.toDartUri(relativeTo: libraryUri).toString()
          ..isNullable = isNullable,
      );
}

String _decapitalize(String s) => s[0].toLowerCase() + s.substring(1);
