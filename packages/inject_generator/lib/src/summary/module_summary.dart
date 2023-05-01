// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of inject.src.summary;

/// Result of analyzing a `@Module()` annotated-class.
@JsonSerializable()
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
    Iterable<ProviderSummary> providers,
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

  factory ModuleSummary.fromJson(Map<String, dynamic> json) => _$ModuleSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ModuleSummaryToJson(this);
}
