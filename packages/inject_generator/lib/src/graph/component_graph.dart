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

  /// Whether or not this dependency is nullable.
  final bool isNullable;

  /// Whether or not this dependency is a singleton.
  final bool isSingleton;

  /// Whether this provider is annotated with `@asynchronous`.
  final bool isAsynchronous;

  /// Transitive dependencies.
  final List<InjectedType> dependencies;

  /// Constructor.
  const ResolvedDependency(
    this.lookupKey,
    this.isNullable,
    this.isSingleton,
    this.isAsynchronous,
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

  DependencyProvidedByModule._(
    super.lookupKey,
    super.isNullable,
    super.isSingleton,
    super.isAsynchronous,
    super.dependencies,
    this.moduleClass,
    this.methodName,
  );
}

/// A dependency provided by an injectable class.
class DependencyProvidedByInjectable extends ResolvedDependency {
  /// Summary about the injectable class.
  final InjectableSummary summary;

  DependencyProvidedByInjectable._(this.summary)
      : super(
          summary.constructor.injectedType.lookupKey,
          false,
          summary.constructor.isSingleton,
          false,
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
          LookupKey(summary.clazz),
          false,
          false,
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

  void debug() {
    final buffer = StringBuffer()
      ..writeln('graph:')
      ..writeln('   includeModules:');

    for (final summary in includeModules) {
      buffer
        ..writeln('      module:')
        ..writeln('         ${summary.clazz.symbol}')
        ..writeln('      provides:')
        ..writeAll(
          summary.providers
              .map(
                (provider) => provider.injectedType.lookupKey.toPrettyString(),
              )
              .map((className) => '         $className\n'),
        );
    }

    buffer
      ..writeln('   providers:')
      ..writeln('      injectedType:')
      ..writeAll(
        providers.map(
          (summary) =>
              '         ${summary.injectedType.lookupKey.toPrettyString()}\n',
        ),
      )
      ..writeln('   mergedDependencies:');

    for (final dependency in mergedDependencies.values) {
      buffer
        ..writeln('      dependency:')
        ..writeln('         ${dependency.lookupKey.toPrettyString()}')
        ..writeln('         depends on::')
        ..writeAll(
          dependency.dependencies
              .map((injectedType) => injectedType.lookupKey.toPrettyString())
              .map((className) => '            $className\n'),
        );
    }

    print(buffer);
  }
}
