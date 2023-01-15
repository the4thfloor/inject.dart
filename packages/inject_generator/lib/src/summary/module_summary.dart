// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of inject.src.summary;

/// Result of analyzing a `@Module()` annotated-class.
class ModuleSummary {
  /// Location of the analyzed class.
  final SymbolPath clazz;

  final bool hasDefaultConstructor;

  /// Providers that are part of the module.
  final List<ProviderSummary> providers;

  /// Create a new summary of a module [clazz] of [providers].
  factory ModuleSummary(
    SymbolPath clazz,
    bool hasDefaultConstructor,
    List<ProviderSummary> providers,
  ) {
    if (providers.isEmpty) {
      throw ArgumentError.value(
        providers,
        'providers',
        'Must not be null or empty.',
      );
    }

    return ModuleSummary._(
      clazz,
      hasDefaultConstructor,
      List<ProviderSummary>.unmodifiable(providers),
    );
  }

  const ModuleSummary._(this.clazz, this.hasDefaultConstructor, this.providers);

  /// Returns a new instance from the JSON encoding of an instance.
  ///
  /// See also [ModuleSummary.toJson].
  factory ModuleSummary.fromJson(Uri assetUri, Map<String, dynamic> json) {
    final name = json['name'] as String;
    final hasDefaultConstructor = json['hasDefaultConstructor'] as bool;
    final providers = json['providers']
        .cast<Map<String, dynamic>>()
        .map<ProviderSummary>(ProviderSummary.fromJson)
        .toList();
    final clazz = SymbolPath.fromAbsoluteUri(assetUri, name);
    return ModuleSummary(clazz, hasDefaultConstructor, providers);
  }

  /// Serializes this summary to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': clazz.symbol,
      'hasDefaultConstructor': hasDefaultConstructor,
      'providers': providers,
    };
  }
}
