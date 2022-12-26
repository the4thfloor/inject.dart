// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
part of inject.src.graph;

/// Assists code generation by doing compile-time analysis of an `@Injector`.
///
/// To use, create an [InjectorGraphResolver] for a `@Injector`-annotated class:
///     var resolver = new InjectorGraphResolver(summaryReader, injectorSummary);
///     var graph = await resolver.resolve();
class InjectorGraphResolver {
  static const String _librarySummaryExtension = '.inject.summary';

  final InjectorSummary _injectorSummary;
  final List<SymbolPath> _modules = <SymbolPath>[];
  final List<ProviderSummary> _providers = <ProviderSummary>[];
  final SummaryReader _reader;

  /// To prevent rereading the same summaries, we cache them here.
  final Map<SymbolPath, LibrarySummary> _summaryCache =
      <SymbolPath, LibrarySummary>{};

  /// Create a new resolver that uses a [SummaryReader].
  InjectorGraphResolver(this._reader, this._injectorSummary) {
    _injectorSummary.modules.forEach(_modules.add);
    _injectorSummary.providers.forEach(_providers.add);
  }

  Future<LibrarySummary> _readFromPath(
    SymbolPath p, {
    required SymbolPath requestedBy,
  }) async {
    final cachedSummary = _summaryCache[p];
    if (cachedSummary != null) {
      return cachedSummary;
    }

    final package = p.package!;
    final filePath = path.withoutExtension(p.path!) + _librarySummaryExtension;
    try {
      return _summaryCache[p] = await _reader.read(package, filePath);
    } on AssetNotFoundException {
      logUnresolvedDependency(
        injectorSummary: _injectorSummary,
        dependency: p,
        requestedBy: requestedBy,
      );
    } on PackageNotFoundException {
      logUnresolvedDependency(
        injectorSummary: _injectorSummary,
        dependency: p,
        requestedBy: requestedBy,
      );
    } on InvalidInputException {
      logUnresolvedDependency(
        injectorSummary: _injectorSummary,
        dependency: p,
        requestedBy: requestedBy,
      );
    } on FileSystemException {
      logUnresolvedDependency(
        injectorSummary: _injectorSummary,
        dependency: p,
        requestedBy: requestedBy,
      );
    } catch (error, stackTrace) {
      builderContext.rawLogger.severe(
        'Unrecognized error trying to find a dependency. '
        'Please file a bug with package:inject.',
        error,
        stackTrace,
      );
    }
    return LibrarySummary(p.toAbsoluteUri());
  }

  /// Return a resolved graph that can be used to generate a `$Injector` class.
  Future<InjectorGraph> resolve() async {
    // For every module, load the corresponding library summary that should have
    // already been built in the dependency tree. We then lookup the specific
    // module summary from the library summary.
    final modulesToLoad = _modules.map<Future<ModuleSummary?>>((module) async {
      final moduleSummaries =
          (await _readFromPath(module, requestedBy: _injectorSummary.clazz))
              .modules;

      final first = moduleSummaries.firstWhereOrNull(
        (s) => s.clazz == module,
      );

      if (first == null) {
        builderContext.rawLogger.severe(
          'Failed to locate summary for module ${module.toAbsoluteUri()} ',
          'specified in injector ${_injectorSummary.clazz.symbol}.',
        );
      }
      return first;
    });
    final allModules = (await Future.wait<ModuleSummary?>(modulesToLoad))
        .whereNotNull()
        .toList();

    final providersByModules = <LookupKey, DependencyProvidedByModule>{};

    // We compute the providers by modules in two passes. The first pass finds
    // all keys that are explicitly provided.
    for (final module in allModules) {
      for (final provider in module.providers) {
        final lookupKey = _extractLookupKey(provider.injectedType);
        providersByModules[lookupKey] = DependencyProvidedByModule._(
          lookupKey,
          provider.isSingleton,
          provider.isAsynchronous,
          provider.dependencies,
          module.clazz,
          provider.name,
        );
      }
    }

    final injectables = <LookupKey, InjectableSummary>{};

    Future<void> addInjectableIfExists(
      LookupKey key, {
      required SymbolPath requestedBy,
    }) async {
      // Modules take precedence.
      final isProvidedByAModule = providersByModules.containsKey(key);
      final isSeen = injectables.containsKey(key);
      if (isProvidedByAModule || isSeen) {
        return;
      }
      if (!key.root.isGlobal) {
        final lib = await _readFromPath(key.root, requestedBy: requestedBy);
        for (final injectable in lib.injectables) {
          if (injectable.clazz == key.root) {
            injectables[key] = injectable;
            for (final dependency in injectable.constructor.dependencies) {
              await addInjectableIfExists(
                dependency.lookupKey,
                requestedBy: injectable.clazz,
              );
            }
          }
        }
      }
    }

    // The second pass looks at all the dependencies for the providers, and if
    // that dependency isn't already met by a module, it satisfies the
    // dependency by using the type's injectable constructor.
    for (final module in allModules) {
      for (final provider in module.providers) {
        for (final dependency in provider.dependencies) {
          await addInjectableIfExists(
            dependency.lookupKey,
            requestedBy: module.clazz,
          );
        }
      }
    }

    for (final injectorProvider in _injectorSummary.providers) {
      await addInjectableIfExists(
        injectorProvider.injectedType.lookupKey,
        requestedBy: _injectorSummary.clazz,
      );
    }

    final providersByInjectables =
        <LookupKey, DependencyProvidedByInjectable>{};
    injectables.forEach((symbol, summary) {
      providersByInjectables[symbol] =
          DependencyProvidedByInjectable._(summary);
    });

    // Combined dependencies provided by injectables with those provided by
    // modules, giving modules a higher precedence.
    final mergedDependencies = <LookupKey, ResolvedDependency>{}
      ..addAll(providersByInjectables)
      ..addAll(providersByModules);

    // Providers defined on the injector class.
    final injectorProviders = <InjectorProvider>[];
    for (final p in _providers) {
      injectorProviders.add(
        InjectorProvider._(
          p.injectedType,
          p.name,
          p.kind == ProviderKind.getter,
        ),
      );
    }

    _detectAndWarnAboutCycles(mergedDependencies);

    return InjectorGraph._(
      List<SymbolPath>.unmodifiable(allModules.map((m) => m.clazz)),
      List<InjectorProvider>.unmodifiable(injectorProviders),
      Map<LookupKey, ResolvedDependency>.unmodifiable(mergedDependencies),
    );
  }

  void _detectAndWarnAboutCycles(
    Map<LookupKey, ResolvedDependency> mergedDependencies,
  ) {
    // Symbols we already inspected as potential roots of a cycle.
    final checkedRoots = <LookupKey>{};

    // Keeps track of cycles we already printed so we do not print them again.
    // This can happen when we find the same cycle starting from a different
    // node. Example, the following three are all the same cycle:
    //
    // a -> b -> c -> a
    // b -> c -> a -> b
    // c -> a -> b -> c
    final cycles = <Cycle>{};

    for (final dependency in mergedDependencies.keys) {
      if (checkedRoots.contains(dependency)) {
        // This symbol was already checked.
        continue;
      }
      checkedRoots.add(dependency);

      final chain = <LookupKey>[];
      void checkForCycles(LookupKey parent) {
        final hasCycle = chain.contains(parent);
        chain.add(parent);
        if (hasCycle) {
          final cycle = chain.sublist(chain.indexOf(parent));
          if (cycles.add(Cycle(cycle))) {
            final formattedCycle = cycle
                .map((s) => '  (${s.toPrettyString()} from ${s.root.path})')
                .join('\n');
            builderContext.rawLogger
                .severe('Detected dependency cycle:\n$formattedCycle');
          }
        } else {
          final children = mergedDependencies[parent]
                  ?.dependencies
                  .map((injectedType) => injectedType.lookupKey) ??
              const [];
          for (final child in children) {
            checkForCycles(child);
          }
        }
        chain.removeLast();
      }

      checkForCycles(dependency);
    }
  }

  static LookupKey _extractLookupKey(InjectedType injectedType) {
    if (injectedType != InjectedType(injectedType.lookupKey)) {
      throw ArgumentError('Extracting the LookupKey from an InjectedType that '
          'has additional metadata. This is a dart:inject bug. '
          'Please file a bug.');
    }
    return injectedType.lookupKey;
  }
}

/// An edge in a dependency graph.
@visibleForTesting
class DependencyEdge {
  /// The dependent node in the dependency graph.
  final LookupKey from;

  /// The dependee node in the dependency graph.
  final LookupKey to;

  DependencyEdge({required this.from, required this.to});

  @override
  int get hashCode => hash2(from, to);

  @override
  bool operator ==(Object other) =>
      other is DependencyEdge && other.from == from && other.to == to;
}

/// Represents a cycle inside a dependency graph.
///
/// Cycles containing identical sets of nodes and edges are considered equal.
/// For example the following cycles are equal:
///
/// A -> B -> C -> A
/// B -> C -> A -> B
/// C -> A -> B -> C
@visibleForTesting
class Cycle {
  static const SetEquality _setEquality = SetEquality<dynamic>();

  final Set<LookupKey> _nodes;
  final Set<DependencyEdge> _edges;

  Cycle(List<LookupKey> chain)
      : _nodes = chain.toSet(),
        _edges = _computeEdgeSet(chain) {
    assert(chain.length > 1);
    assert(chain.first == chain.last);
    assert(_nodes.length == chain.length - 1);
    assert(_edges.length == chain.length - 1);
  }

  static Set<DependencyEdge> _computeEdgeSet(List<LookupKey> chain) {
    final result = <DependencyEdge>{};
    for (var i = 0; i < chain.length - 1; i++) {
      result.add(DependencyEdge(from: chain[i], to: chain[i + 1]));
    }
    return result;
  }

  /// Hashes only nodes, but not edges, because it should be good enough, and
  /// because hash code must be order-independent.
  // IMPORTANT: we intentionally do not use Quiver's hashObjects because it is
  // order-dependent.
  @override
  int get hashCode => _nodes.fold(0, (hash, s) => hash + s.hashCode);

  @override
  bool operator ==(Object other) {
    if (other is Cycle) {
      return _setEquality.equals(_nodes, other._nodes) &&
          _setEquality.equals(_edges, other._edges);
    }
    return false;
  }
}

/// Logs an error message for a dependency that can not be resolved.
///
/// Since the DI graph can not be created with an unfulfilled dependency, this
/// logs a severe error.
void logUnresolvedDependency({
  required InjectorSummary injectorSummary,
  required SymbolPath dependency,
  required SymbolPath requestedBy,
}) {
  final injectorClassName = injectorSummary.clazz.symbol;
  final dependencyClassName = dependency.symbol;
  final requestedByClassName = requestedBy.symbol;
  builderContext.rawLogger.severe(
      '''Could not find a way to provide "$dependencyClassName" for injector "$injectorClassName" which is injected in "$requestedByClassName".

To fix this, check that at least one of the following is true:

- Ensure that $dependencyClassName's class declaration or constructor is annotated with @provide.

- Ensure $injectorClassName contains a module that provides $dependencyClassName.

These classes were found at the following paths:

- Injector ($injectorClassName): ${injectorSummary.clazz.toAbsoluteUri().removeFragment()}.

- Injected class ($dependencyClassName): ${dependency.toAbsoluteUri().removeFragment()}.

- Injected in class ($requestedByClassName): ${requestedBy.toAbsoluteUri().removeFragment()}.
''');
}
