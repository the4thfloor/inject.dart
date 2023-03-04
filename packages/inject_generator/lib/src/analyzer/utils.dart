// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';

import '../context.dart';
import '../source/injected_type.dart';
import '../source/lookup_key.dart';
import '../source/symbol_path.dart';

/// Constructs a serializable path to [element].
SymbolPath getSymbolPath(Element element) {
  if (element is TypeDefiningElement && element.kind == ElementKind.DYNAMIC) {
    throw ArgumentError('Dynamic element type not supported. This is a '
        'package:inject bug. Please report it.');
  }
  return SymbolPath.fromAbsoluteUri(
    element.library!.source.uri,
    element.name,
  );
}

/// Constructs a [InjectedType] from a [DartType].
InjectedType getInjectedType(
  DartType type, {
  String? name,
  bool? required,
  bool? named,
  SymbolPath? qualifier,
  bool? assisted,
}) {
  if (type is FunctionType) {
    if (type.parameters.isNotEmpty) {
      builderContext.log.severe(
          type.element,
          'Only no-arg typedefs are supported, '
          'and no-arg typedefs are treated as providers of the return type. ');
      throw ArgumentError();
    }
    if (type.returnType.isDynamic) {
      builderContext.log.severe(
          type.element,
          'Cannot create a provider of type dynamic. '
          'Your function type did not include a return type.');
      throw ArgumentError();
    }
    return InjectedType(
      LookupKey.fromDartType(type.returnType, qualifier: qualifier),
      name: name,
      isRequired: required,
      isNamed: named,
      isProvider: true,
      isAssisted: assisted,
    );
  }

  final asyncFuture = type.isDartAsyncFuture;
  final futureType = asyncFuture && type is ParameterizedType
      ? type.typeArguments.firstOrNull
      : null;

  return InjectedType(
    LookupKey.fromDartType(futureType ?? type, qualifier: qualifier),
    name: name,
    isRequired: required,
    isNamed: named,
    isProvider: false,
    isFeature: asyncFuture,
    isAssisted: assisted,
  );
}

bool _hasAnnotation(Element element, SymbolPath annotationSymbol) {
  return _getAnnotation(element, annotationSymbol, orElse: () => null) != null;
}

ElementAnnotation? _getAnnotation(
  Element element,
  SymbolPath annotationSymbol, {
  ElementAnnotation? Function()? orElse,
}) {
  final resolvedMetadata = element.metadata;

  for (var i = 0; i < resolvedMetadata.length; i++) {
    final annotation = resolvedMetadata[i];
    final valueElement = annotation.computeConstantValue()?.type?.element;

    if (valueElement == null) {
      final pathToAnnotation = annotationSymbol.toHumanReadableString();
      builderContext.log.severe(
        annotation.element ?? element,
        'While looking for annotation $pathToAnnotation on "$element", '
        'failed to resolve annotation value. A common cause of this error is '
        'a misspelling or a failure to resolve the import where the '
        'annotation comes from.',
      );
    } else if (getSymbolPath(valueElement) == annotationSymbol) {
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
bool isInjectableClass(ClassElement clazz) =>
    hasInjectAnnotation(clazz) || clazz.constructors.any(hasInjectAnnotation);

/// Determines if [clazz] is an assisted injectable class.
///
/// Injectability is determined by checking if the class declaration or one of
/// its constructors is annotated with `@AssistedInject()`.
bool isAssistedInjectableClass(ClassElement clazz) =>
    hasAssistedInjectAnnotation(clazz) ||
    clazz.constructors.any(hasAssistedInjectAnnotation);

/// Determines if [clazz] is an AssistedInjection factory class.
///
/// AssistedInjection factory is determined by checking if the class declaration
/// is annotated with `@AssistedFactory()`.
bool isAssistedFactoryClass(ClassElement clazz) =>
    hasAssistedFactoryAnnotation(clazz);

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
      builderContext.log.severe(
          clazz,
          'A class cannot be annotated with `@singleton` '
          'without also being annotated `@inject`. '
          'Did you forget to add an `@inject` annotation '
          'to class ${clazz.name}?');
    }
  }
  for (final constructor in clazz.constructors) {
    if (hasSingletonAnnotation(constructor)) {
      if (hasInjectAnnotation(constructor)) {
        isSingleton = true;
      } else {
        builderContext.log.severe(
            constructor,
            'A constructor cannot be annotated with `@Singleton()` '
            'without also being annotated `@Inject()`. '
            'Did you forget to add an `@Inject()` annotation '
            'to the constructor ${constructor.name}?');
      }
    }
  }
  return isSingleton;
}

/// Whether [clazz] is annotated with `@Module()`.
bool isModuleClass(ClassElement clazz) =>
    _hasAnnotation(clazz, SymbolPath.module);

/// Whether [clazz] is annotated with `@Component()`.
bool isComponentClass(ClassElement clazz) => hasComponentAnnotation(clazz);

/// Whether [e] is annotated with `@Inject()`.
bool hasInjectAnnotation(Element e) => _hasAnnotation(e, SymbolPath.inject);

/// Whether [e] is annotated with `@AssistedInject()`.
bool hasAssistedInjectAnnotation(Element e) =>
    _hasAnnotation(e, SymbolPath.assistedInject);

/// Whether [e] is annotated with `@AssistedFactory()`.
bool hasAssistedFactoryAnnotation(Element e) =>
    _hasAnnotation(e, SymbolPath.assistedFactory);

/// Whether [e] is annotated with `@Assisted()`.
bool hasAssistedAnnotation(Element e) => _hasAnnotation(e, SymbolPath.assisted);

/// Whether [e] is annotated with `@Provides()`.
bool hasProvidesAnnotation(Element e) => _hasAnnotation(e, SymbolPath.provides);

/// Whether [e] is annotated with `@Singleton()`.
bool hasSingletonAnnotation(Element e) =>
    _hasAnnotation(e, SymbolPath.singleton);

/// Whether [e] is annotated with `@Asynchronous()`.
bool hasAsynchronousAnnotation(Element e) =>
    _hasAnnotation(e, SymbolPath.asynchronous);

/// Whether [e] is annotated with `@Qualifier(...)`.
bool hasQualifier(Element e) => _hasAnnotation(e, SymbolPath.qualifier);

/// Returns a global key for the `@Qualifier` annotated method.
SymbolPath extractQualifier(Element e) {
  final metadata = _getAnnotation(e, SymbolPath.qualifier);
  final key =
      metadata!.computeConstantValue()!.getField('name')!.toSymbolValue();
  return SymbolPath.global(key!);
}

/// Whether [e] is annotated with `@Component()`.
bool hasComponentAnnotation(Element e) =>
    _hasAnnotation(e, SymbolPath.component);

/// Returns the element corresponding to the `@Component()` annotation.
///
/// Throws if the annotation is missing. It is assumed that the calling code
/// already verified the existence of the annotation using
/// [hasComponentAnnotation].
ElementAnnotation? getComponentAnnotation(Element e) =>
    _getAnnotation(e, SymbolPath.component);

/// Returns the element corresponding to the `@AssistedInject()` annotation.
///
/// Throws if the annotation is missing. It is assumed that the calling code
/// already verified the existence of the annotation using
/// [hasAssistedInjectAnnotation].
ElementAnnotation? getAssistedInjectAnnotation(Element e) =>
    _getAnnotation(e, SymbolPath.assistedInject);

extension IsNullable on DartType {
  bool isNullable() => nullabilitySuffix == NullabilitySuffix.question;
}
