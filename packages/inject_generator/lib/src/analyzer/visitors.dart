// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:collection/collection.dart';

import '../context.dart';
import '../source/symbol_path.dart';
import 'utils.dart';

/// Scans a resolved [LibraryElement] looking for metadata-annotated members.
///
/// Looks for:
/// - [visitInjectable]: Classes or constructors annotated with `@provide`.
/// - [visitComponent]: Classes annotated with `@component`.
/// - [visitModule]: Classes annotated with `@module`.
abstract class InjectLibraryVisitor {
  /// Call to start visiting [library].
  void visitLibrary(LibraryElement library) {
    _LibraryVisitor(this).visitLibraryElement(library);
  }

  /// Called when [clazz] is annotated with `@provide`.
  ///
  /// If [clazz] is annotated with `@singleton`, then [singleton] is true.
  void visitInjectable(ClassElement clazz, bool singleton);

  /// Called when [clazz] is annotated with `@component`.
  ///
  /// [modules] is the list of types supplied as modules in the annotation.
  ///
  /// Example:
  ///
  ///     @Component(const [FooModule, BarModule])
  ///     class Services {
  ///       ...
  ///     }
  ///
  /// In this example, [modules] will contain references to `FooModule` and
  /// `BarModule` types.
  void visitComponent(ClassElement clazz, List<SymbolPath> modules);

  /// Called when [clazz] is annotated with `@module`.
  void visitModule(ClassElement clazz);
}

class _LibraryVisitor extends RecursiveElementVisitor<void> {
  final InjectLibraryVisitor _injectLibraryVisitor;

  _LibraryVisitor(this._injectLibraryVisitor);

  @override
  void visitClassElement(ClassElement element) {
    var isInjectable = false;
    var isModule = false;
    var isComponent = false;

    var count = 0;
    if (isModuleClass(element)) {
      isModule = true;
      count++;
    }
    if (isInjectableClass(element)) {
      isInjectable = true;
      count++;
    }
    if (isComponentClass(element)) {
      isComponent = true;
      count++;
    }

    if (count > 1) {
      final types = [
        isInjectable ? 'injectable' : null,
        isModule ? 'module' : null,
        isComponent ? 'component' : null,
      ].where((t) => t != null);

      builderContext.log.severe(
        element,
        'A class may be an injectable, a module or an component, '
        'but not more than one of these types. However class '
        '${element.name} was found to be ${types.join(' and ')}',
      );
      return;
    }

    if (isModule) {
      _injectLibraryVisitor.visitModule(element);
    }
    if (isInjectable) {
      final singleton = isSingletonClass(element);
      final asynchronous = hasAsynchronousAnnotation(element) ||
          element.constructors.any(hasAsynchronousAnnotation);
      if (asynchronous) {
        builderContext.log.severe(
          element,
          'Classes and constructors cannot be annotated with @Asynchronous().',
        );
      }
      _injectLibraryVisitor.visitInjectable(
        element,
        singleton,
      );
    }
    if (isComponent) {
      _injectLibraryVisitor.visitComponent(
        element,
        _extractModules(element),
      );
    }
    return;
  }
}

List<SymbolPath> _extractModules(ClassElement clazz) {
  final annotation = getComponentAnnotation(clazz);
  final modules =
      annotation?.computeConstantValue()?.getField('modules')?.toListValue();
  if (modules == null) {
    return const <SymbolPath>[];
  }
  return modules
      .map((obj) => obj.toTypeValue()?.element)
      .whereNotNull()
      .map((element) => getSymbolPath(element))
      .toList();
}

/// Scans a resolved [ClassElement] looking for metadata-annotated members.
abstract class InjectClassVisitor {
  final bool _isForComponent;

  /// Constructor.
  const InjectClassVisitor(this._isForComponent);

  /// Whether we are collecting providers for an component class or a module class.
  bool get isForComponent => _isForComponent;

  /// Call to start visiting [clazz].
  void visitClass(ClassElement clazz) {
    for (final supertype
        in clazz.allSupertypes.where((t) => !t.isDartCoreObject)) {
      _AnnotatedClassVisitor(this).visitElement(supertype.element);
    }
    _AnnotatedClassVisitor(this).visitClassElement(clazz);
  }

  /// Called when a method is annotated with `@provide`.
  ///
  /// [singleton] is `true` when the method is also annotated with
  /// `@singleton`.
  ///
  /// [asynchronous] is `true` when the method is also annotated with
  /// `@asynchronous`.
  ///
  /// [qualifier] is non-null when the method is also annotated with
  /// an annotation created by `const Qualifier(...)`.
  void visitProvideMethod(
    MethodElement method,
    bool singleton,
    bool asynchronous, {
    SymbolPath? qualifier,
  });

  /// Called when a getter is annotated with `@provide`.
  ///
  /// [singleton] is `true` when the getter is also annotated with
  /// `@singleton`.
  void visitProvideGetter(FieldElement method, bool singleton);
}

class _AnnotatedClassVisitor extends GeneralizingElementVisitor<void> {
  final InjectClassVisitor _classVisitor;

  const _AnnotatedClassVisitor(this._classVisitor);

  // - true, if it is a component and has the `@inject` annotation
  // - true, if it is a component and the element is abstract
  //   unlike modules, the `@inject` annotation is optional in components
  // - true, if it is a module and has the `@provides` annotation
  bool _isProvider(ExecutableElement element) {
    if (_classVisitor._isForComponent) {
      return (hasInjectAnnotation(element) || element.isAbstract) &&
          !hasProvidesAnnotation(element);
    } else {
      return hasProvidesAnnotation(element);
    }
  }

  @override
  void visitMethodElement(MethodElement method) {
    if (_isProvider(method)) {
      final singleton = hasSingletonAnnotation(method);
      final asynchronous = hasAsynchronousAnnotation(method);
      _classVisitor.visitProvideMethod(
        method,
        singleton,
        asynchronous,
        qualifier: hasQualifier(method) ? extractQualifier(method) : null,
      );
    } else if (_classVisitor._isForComponent && hasProvidesAnnotation(method)) {
      builderContext.log.warning(
        method,
        '@provides annotation is not supported for components',
      );
    } else if (!_classVisitor._isForComponent && hasInjectAnnotation(method)) {
      builderContext.log.warning(
        method,
        '@inject annotation is not supported for modules',
      );
    }
  }

  @override
  void visitFieldElement(FieldElement field) {
    if (_isProvider(field.getter!)) {
      final singleton = hasSingletonAnnotation(field);
      final asynchronous = hasAsynchronousAnnotation(field);
      if (asynchronous) {
        builderContext.log.severe(
          field,
          'Getters cannot be annotated with @Asynchronous().',
        );
      }
      _classVisitor.visitProvideGetter(field, singleton);
    } else if (_classVisitor._isForComponent &&
        hasProvidesAnnotation(field.getter!)) {
      builderContext.log.warning(
        field.getter!,
        '@provides annotation is not supported for components',
      );
    } else if (!_classVisitor._isForComponent &&
        hasInjectAnnotation(field.getter!)) {
      builderContext.log.warning(
        field.getter!,
        '@inject annotation is not supported for modules',
      );
    }
    return;
  }
}
