// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of inject.src.summary;

/// JSON-serializable subset of code analysis information about an component
/// class pertaining to an component class.
@JsonSerializable()
class ComponentSummary {
  /// Location of the analyzed class.
  final SymbolPath clazz;

  /// Modules that are part of the object graph.
  final List<SymbolPath> modules;

  /// Methods that will need to be implemented by the generated class.
  final List<ProviderSummary> providers;

  /// Constructor.
  ///
  /// [clazz], [modules] and [providers] must not be `null` or empty.
  factory ComponentSummary(
    SymbolPath clazz,
    List<SymbolPath> modules,
    Iterable<ProviderSummary> providers,
  ) {
    return ComponentSummary._(
      clazz,
      List<SymbolPath>.unmodifiable(modules),
      List<ProviderSummary>.unmodifiable(providers),
    );
  }

  const ComponentSummary._(this.clazz, this.modules, this.providers);

  factory ComponentSummary.fromJson(Map<String, dynamic> json) => _$ComponentSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$ComponentSummaryToJson(this);
}
