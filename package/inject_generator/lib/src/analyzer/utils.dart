// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

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
InjectedType getInjectedType(DartType type, {SymbolPath? qualifier}) {
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
      _getLookupKey(type.returnType, qualifier: qualifier),
      isProvider: true,
    );
  }

  return InjectedType(
    _getLookupKey(type, qualifier: qualifier),
    isProvider: false,
  );
}

LookupKey _getLookupKey(DartType type, {SymbolPath? qualifier}) =>
    LookupKey(getSymbolPath(type.element!), qualifier: qualifier);

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
      : throw 'Annotation $annotationSymbol not found on element $element';
}

/// Determines if [clazz] is an injectable class.
///
/// Injectability is determined by checking if the class declaration or one of
/// its constructors is annotated with `@Provide()`.
bool isInjectableClass(ClassElement clazz) =>
    hasProvideAnnotation(clazz) || clazz.constructors.any(hasProvideAnnotation);

/// Determines if [clazz] is a singleton class.
///
/// A class is a singleton if:
///     1. the class declaration is tagged with both `@Provide()` and
///        `@Singleton()`, or
///     2. one of the constructors is tagged with both `@Provide()` and
///        `@Singleton()`.
///
/// It is a warning to have an `@Singleton()` annotation without an `@Provide()`
/// annotation.
bool isSingletonClass(ClassElement clazz) {
  var isSingleton = false;
  if (hasSingletonAnnotation(clazz)) {
    if (hasProvideAnnotation(clazz)) {
      isSingleton = true;
    } else {
      builderContext.log.severe(
          clazz,
          'A class cannot be annotated with `@singleton` '
          'without also being annotated `@provide`. '
          'Did you forget to add an `@provide` annotation '
          'to class ${clazz.name}?');
    }
  }
  for (final constructor in clazz.constructors) {
    if (hasSingletonAnnotation(constructor)) {
      if (hasProvideAnnotation(constructor)) {
        isSingleton = true;
      } else {
        builderContext.log.severe(
            constructor,
            'A constructor cannot be annotated with `@Singleton()` '
            'without also being annotated `@Provide()`. '
            'Did you forget to add an `@Provide()` annotation '
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

/// Whether [e] is annotated with `@Provide()`.
bool hasProvideAnnotation(Element e) => _hasAnnotation(e, SymbolPath.provide);

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
