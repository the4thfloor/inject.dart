// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of inject.src.graph;

/// A provider defined on an `@Component` class.
class ComponentProvider {
  /// The type this provides.
  final InjectedType injectedType;

  /// The name of the method or getter to `@override`.
  final String methodName;

  /// Whether this provider is a getter.
  final bool isGetter;

  ComponentProvider._(this.injectedType, this.methodName, this.isGetter);
}

/// A dependency resolved to a concrete provider.
abstract class ResolvedDependency {
  /// The key of the dependency.
  final LookupKey lookupKey;

  /// Whether or not this dependency is a singleton.
  final bool isSingleton;

  /// Transitive dependencies.
  final List<InjectedType> dependencies;

  /// Constructor.
  const ResolvedDependency(
    this.lookupKey,
    this.isSingleton,
    this.dependencies,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResolvedDependency &&
          runtimeType == other.runtimeType &&
          lookupKey == other.lookupKey;

  @override
  int get hashCode => lookupKey.hashCode;
}

/// A dependency provided by a module class.
class DependencyProvidedByModule extends ResolvedDependency {
  /// Module that provides the dependency.
  final SymbolPath moduleClass;

  /// Name of the method in the class.
  final String methodName;

  /// Whether this provider is annotated with `@asynchronous`.
  final bool isAsynchronous;

  DependencyProvidedByModule._(
    super.lookupKey,
    super.singleton,
    super.dependencies,
    this.moduleClass,
    this.methodName,
    this.isAsynchronous,
  );
}

/// A dependency provided by an injectable class.
class DependencyProvidedByInjectable extends ResolvedDependency {
  /// Summary about the injectable class.
  final InjectableSummary summary;

  DependencyProvidedByInjectable._(this.summary)
      : super(
          LookupKey(summary.clazz, isNullable: false),
          summary.constructor.isSingleton,
          summary.constructor.dependencies,
        );
}

/// A dependency provided by an factory class.
class DependencyProvidedByFactory extends ResolvedDependency {
  /// Summary about the factory.
  final FactorySummary summary;

  /// Summary about the created class.
  final InjectableSummary injectable;

  DependencyProvidedByFactory._(this.summary, this.injectable)
      : super(
          LookupKey(summary.clazz, isNullable: false),
          false,
          injectable.constructor.dependencies,
        );
}

/// All of the data that is needed to generate an `@Component` class.
class ComponentGraph {
  /// Modules used by the component.
  final List<ModuleSummary> includeModules;

  /// Providers that should be generated.
  final List<ComponentProvider> providers;

  /// Dependencies resolved to concrete providers mapped from key.
  final Map<LookupKey, ResolvedDependency> mergedDependencies;

  ComponentGraph._(
    this.includeModules,
    this.providers,
    this.mergedDependencies,
  );
}
