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

  factory LibrarySummary.fromJson(Map<String, dynamic> json) =>
      _$LibrarySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$LibrarySummaryToJson(this);
}
