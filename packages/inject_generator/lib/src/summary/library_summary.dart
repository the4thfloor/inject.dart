// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of inject.src.summary;

/// JSON-serializable subset of code analysis information about a Dart library
/// containing dependency injection constructs.
///
/// A library summary generally corresponds to a ".dart" file.
class LibrarySummary {
  /// Points to the Dart file that defines the library from which this summary
  /// was extracted.
  ///
  /// The URI uses the "asset:" scheme.
  final Uri assetUri;

  /// Component classes defined in the library.
  final List<ComponentSummary> components;

  /// Module classes defined in this library.
  final List<ModuleSummary> modules;

  /// Injectable classes.
  final List<InjectableSummary> injectables;

  /// AssistedInject factory classes.
  final List<FactorySummary> factories;

  /// Constructor.
  ///
  /// [assetUri], [components] and [modules] must not be `null`.
  factory LibrarySummary(
    Uri assetUri, {
    List<ComponentSummary> components = const [],
    List<ModuleSummary> modules = const [],
    List<InjectableSummary> injectables = const [],
    List<FactorySummary> factories = const [],
  }) {
    return LibrarySummary._(
      assetUri,
      components,
      modules,
      injectables,
      factories,
    );
  }

  const LibrarySummary._(
    this.assetUri,
    this.components,
    this.modules,
    this.injectables,
    this.factories,
  );

  /// Creates a [LibrarySummary] by parsing the .inject.summary [json].
  ///
  /// See also [LibrarySummary.toJson].
  factory LibrarySummary.fromJson(Map<String, dynamic> json) {
    final assetUri = Uri.parse(json['asset'] as String);
    final summary = json['summary'] as Map<String, dynamic>;
    final components = (summary['component'] as List<dynamic>)
        .map(
          (e) => ComponentSummary.fromJson(assetUri, e as Map<String, dynamic>),
        )
        .toList();
    final modules = (summary['module'] as List<dynamic>)
        .map(
          (e) => ModuleSummary.fromJson(assetUri, e as Map<String, dynamic>),
        )
        .toList();
    final injectables = (summary['injectable'] as List<dynamic>)
        .map(
          (e) =>
              InjectableSummary.fromJson(assetUri, e as Map<String, dynamic>),
        )
        .toList();
    final factories = (summary['factories'] as List<dynamic>)
        .map(
          (e) => FactorySummary.fromJson(assetUri, e as Map<String, dynamic>),
        )
        .toList();
    return LibrarySummary(
      assetUri,
      components: components,
      modules: modules,
      injectables: injectables,
      factories: factories,
    );
  }

  /// Serializes this summary to JSON.
  Map<String, dynamic> toJson() {
    return {
      'asset': assetUri.toString(),
      'summary': {
        'component': components,
        'module': modules,
        'injectable': injectables,
        'factories': factories,
      }
    };
  }
}
