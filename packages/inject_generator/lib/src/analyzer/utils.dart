// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:source_gen/source_gen.dart';

import '../context.dart';
import '../source/injected_type.dart';
import '../source/lookup_key.dart';
import '../source/symbol_path.dart';

/// Constructs a serializable path to [type].
SymbolPath getSymbolPath(DartType type) {
  if (type is DynamicType) {
    throw ArgumentError('Dynamic element type not supported. This is a '
        'package:inject bug. Please report it.');
  }

  return SymbolPath.fromAbsoluteUri(type.uri, typeNameOf(type));
}

/// Constructs a [InjectedType] from a [DartType].
InjectedType getInjectedType(
  DartType type, {
  List<LibraryElement>? importedLibraries,
  String? name,
  SymbolPath? qualifier,
  bool? required,
  bool? named,
  bool? singleton,
  bool? assisted,
}) {
  if (importedLibraries != null) {
    final import = _importUri(type, importedLibraries);
    print('injected type: ${type.name} - import: $import');
  }

  return InjectedType(
    LookupKey.fromDartType(_reducedType(type, name), qualifier: qualifier),
    name: name,
    isNullable: type.isNullable,
    isRequired: required,
    isNamed: named,
    isProvider: type.isProvider,
    isSingleton: singleton,
    isAsynchronous: type.isDartAsyncFuture,
    isAssisted: assisted,
  );
}

Uri? _importUri(DartType type, List<LibraryElement> importedLibraries) {
  final visited = <Uri>[];

  bool foo(LibraryElement lib) {
    if (visited.contains(lib.librarySource.uri)) {
      return false;
    }
    visited.add(lib.librarySource.uri);

    final importExports = [lib, ...lib.importedLibraries, ...lib.exportedLibraries];
    final import = importExports.firstWhereOrNull((element) => element.source.uri == type.uri);
    if (import != null) {
      return true;
    }

    for (final importExport in importExports) {
      if (foo(importExport)) {
        return true;
      }
    }

    return false;
  }

  for (final imported in importedLibraries) {
    final found = foo(imported);
    if (found) {
      return imported.librarySource.uri;
    }
  }

  return null;
}

// Removing [Provider] and [Feature] and use its type argument.
//
// We cannot inject the [Provider] class because it is neither a Dart core
// class nor is it user-implemented.
//
// We also do not inject [Feature]s. We find out whether the injected type
// needs to be provided asynchronously or not, and if it needs to be provided
// asynchronously, we wrap the injected type in a [Feature].
DartType _reducedType(DartType type, String? name) {
  if (!type.isProvider && !type.isDartAsyncFuture) {
    return type;
  }

  if (type is! ParameterizedType) {
    throw 'Generic type for `${type.getDisplayString(withNullability: false)} $name` not specified.';
  }

  final providedType = (type).typeArguments.firstOrNull;
  if (providedType == null || providedType is DynamicType) {
    throw 'Generic type for `${type.getDisplayString(withNullability: false)} $name` not specified.';
  }
  return _reducedType(providedType, name);
}

bool _hasAnnotation(Element element, SymbolPath annotationSymbol) =>
    _getAnnotation(element, annotationSymbol, orElse: () => null) != null;

ElementAnnotation? _getAnnotation(
  Element element,
  SymbolPath annotationSymbol, {
  ElementAnnotation? Function()? orElse,
}) {
  final resolvedMetadata = element.metadata;

  for (var i = 0; i < resolvedMetadata.length; i++) {
    final annotation = resolvedMetadata[i];
    final type = annotation.computeConstantValue()?.type;

    if (type == null) {
      final pathToAnnotation = annotationSymbol.toHumanReadableString();

      throw StateError(
        constructMessage(
          builderContext.buildStep.inputId,
          annotation.element ?? element,
          'While looking for annotation $pathToAnnotation on "$element", '
          'failed to resolve annotation value. A common cause of this error is '
          'a misspelling or a failure to resolve the import where the '
          'annotation comes from.',
        ),
      );
    } else if (getSymbolPath(type) == annotationSymbol) {
      return annotation;
    }
  }

  return orElse != null
      ? orElse()
      : throw 'Annotation ${annotationSymbol.toHumanReadableString()} not found on element $element';
}

/// Determines if [clazz] is an injectable class.
///
/// Injectability is determined by checking if the class declaration or one of
/// its constructors is annotated with `@Inject()`.
bool isInjectableClass(ClassElement clazz) => hasInjectAnnotation(clazz) || clazz.constructors.any(hasInjectAnnotation);

/// Determines if [clazz] is an assisted injectable class.
///
/// Injectability is determined by checking if the class declaration or one of
/// its constructors is annotated with `@AssistedInject()`.
bool isAssistedInjectableClass(ClassElement clazz) =>
    hasAssistedInjectAnnotation(clazz) || clazz.constructors.any(hasAssistedInjectAnnotation);

/// Determines if [clazz] is an AssistedInjection factory class.
///
/// AssistedInjection factory is determined by checking if the class declaration
/// is annotated with `@AssistedFactory()`.
bool isAssistedFactoryClass(ClassElement clazz) => hasAssistedFactoryAnnotation(clazz);

/// Determines if [clazz] is a singleton class.
///
/// A class is a singleton if:
///     1. the class declaration is tagged with both `@Inject()` and
///        `@Singleton()`, or
///     2. one of the constructors is tagged with both `@Inject()` and
///        `@Singleton()`.
///
/// It is a warning to have an `@Singleton()` annotation without an `@Inject()`
/// annotation.
bool isSingletonClass(ClassElement clazz) {
  var isSingleton = false;
  if (hasSingletonAnnotation(clazz)) {
    if (hasInjectAnnotation(clazz)) {
      isSingleton = true;
    } else {
      throw StateError(
        constructMessage(
          builderContext.buildStep.inputId,
          clazz,
          'A class cannot be annotated with `@singleton` '
          'without also being annotated `@inject`. '
          'Did you forget to add an `@inject` annotation '
          'to class ${clazz.name}?',
        ),
      );
    }
  }
  for (final constructor in clazz.constructors) {
    if (hasSingletonAnnotation(constructor)) {
      if (hasInjectAnnotation(constructor)) {
        isSingleton = true;
      } else {
        throw StateError(
          constructMessage(
              builderContext.buildStep.inputId,
              constructor,
              'A constructor cannot be annotated with `@Singleton()` '
              'without also being annotated `@Inject()`. '
              'Did you forget to add an `@Inject()` annotation '
              'to the constructor ${constructor.name}?'),
        );
      }
    }
  }
  return isSingleton;
}

/// Whether [clazz] is annotated with `@Module()`.
bool isModuleClass(ClassElement clazz) => _hasAnnotation(clazz, SymbolPath.module);

/// Whether [clazz] is annotated with `@Component()`.
bool isComponentClass(ClassElement clazz) => hasComponentAnnotation(clazz);

/// Whether [e] is annotated with `@Inject()`.
bool hasInjectAnnotation(Element e) => _hasAnnotation(e, SymbolPath.inject);

/// Whether [e] is annotated with `@AssistedInject()`.
bool hasAssistedInjectAnnotation(Element e) => _hasAnnotation(e, SymbolPath.assistedInject);

/// Whether [e] is annotated with `@AssistedFactory()`.
bool hasAssistedFactoryAnnotation(Element e) => _hasAnnotation(e, SymbolPath.assistedFactory);

/// Whether [e] is annotated with `@Assisted()`.
bool hasAssistedAnnotation(Element e) => _hasAnnotation(e, SymbolPath.assisted);

/// Whether [e] is annotated with `@Provides()`.
bool hasProvidesAnnotation(Element e) => _hasAnnotation(e, SymbolPath.provides);

/// Whether [e] is annotated with `@Singleton()`.
bool hasSingletonAnnotation(Element e) => _hasAnnotation(e, SymbolPath.singleton);

/// Whether [e] is annotated with `@Asynchronous()`.
bool hasAsynchronousAnnotation(Element e) => _hasAnnotation(e, SymbolPath.asynchronous);

/// Whether [e] is annotated with `@Qualifier(...)`.
bool hasQualifier(Element e) => _hasAnnotation(e, SymbolPath.qualifier);

/// Returns a global key for the `@Qualifier` annotated method.
SymbolPath extractQualifier(Element e) {
  final metadata = _getAnnotation(e, SymbolPath.qualifier);
  final key = metadata!.computeConstantValue()!.getField('name')!.toSymbolValue();
  return SymbolPath.global(key!);
}

/// Whether [e] is annotated with `@Component()`.
bool hasComponentAnnotation(Element e) => _hasAnnotation(e, SymbolPath.component);

/// Returns the element corresponding to the `@Component()` annotation.
///
/// Throws if the annotation is missing. It is assumed that the calling code
/// already verified the existence of the annotation using
/// [hasComponentAnnotation].
ElementAnnotation? getComponentAnnotation(Element e) => _getAnnotation(e, SymbolPath.component);

/// Returns the element corresponding to the `@AssistedInject()` annotation.
///
/// Throws if the annotation is missing. It is assumed that the calling code
/// already verified the existence of the annotation using
/// [hasAssistedInjectAnnotation].
ElementAnnotation? getAssistedInjectAnnotation(Element e) => _getAnnotation(e, SymbolPath.assistedInject);

extension DartTypeExtensions on DartType {
  bool get isNullable => nullabilitySuffix == NullabilitySuffix.question;

  bool get isProvider =>
      element?.name == 'Provider' &&
      element?.library?.source.uri == Uri.parse('package:inject_annotation/src/api/provider.dart');

  Uri get uri {
    final dartType = this;
    final aliasElement = dartType.alias?.element;
    if (aliasElement != null) {
      return aliasElement.librarySource.uri;
    }
    if (dartType is InterfaceType) {
      return dartType.element.librarySource.uri;
    }
    if (dartType is TypeParameterType) {
      return dartType.element.librarySource!.uri;
    }
    throw UnimplementedError('(${dartType.runtimeType}) $dartType');
  }
}
