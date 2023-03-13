// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of inject.src.summary;

/// JSON-serializable subset of code analysis information about a Dart library
/// containing dependency injection constructs.
///
/// A library summary generally corresponds to a ".dart" file.
@JsonSerializable()
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

  /// Assisted injectable classes.
  final List<InjectableSummary> assistedInjectables;

  /// AssistedInject factory classes.
  final List<FactorySummary> factories;

  /// Constructor.
  factory LibrarySummary(
    Uri assetUri, {
    List<ComponentSummary> components = const [],
    List<ModuleSummary> modules = const [],
    List<InjectableSummary> injectables = const [],
    List<InjectableSummary> assistedInjectables = const [],
    List<FactorySummary> factories = const [],
  }) {
    return LibrarySummary._(
      assetUri,
      components,
      modules,
      injectables,
      assistedInjectables,
      factories,
    );
  }

  const LibrarySummary._(
    this.assetUri,
    this.components,
    this.modules,
    this.injectables,
    this.assistedInjectables,
    this.factories,
  );

  factory LibrarySummary.fromJson(Map<String, dynamic> json) =>
      _$LibrarySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$LibrarySummaryToJson(this);
}
