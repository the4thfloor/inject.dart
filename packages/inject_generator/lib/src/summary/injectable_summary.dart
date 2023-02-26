// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of inject.src.summary;

/// Result of analyzing a class whose constructor is annotated with `@Inject()`.
class InjectableSummary {
  /// Location of the analyzed class.
  final SymbolPath clazz;

  /// Summary about the constructor annotated with `@Inject()`.
  final ProviderSummary constructor;

  /// The factory of an class annotated with `@AssistedInject()`..
  final LookupKey? factory;

  /// Constructor.
  ///
  /// [clazz] is the path to the injectable class. [constructor] carries summary
  /// about the constructor annotated with `@Inject()`.
  const InjectableSummary(this.clazz, this.constructor, this.factory);

  /// Returns a new instance from the JSON encoding of an instance.
  ///
  /// See also [InjectableSummary.toJson].
  factory InjectableSummary.fromJson(Uri assetUri, Map<String, dynamic> json) {
    final name = json['name'] as String;
    final factory = json['factory'];
    final type = SymbolPath.fromAbsoluteUri(assetUri, name);
    return InjectableSummary(
      type,
      ProviderSummary.fromJson(json['constructor']),
      factory != null ? LookupKey.fromJson(factory) : null,
    );
  }

  /// Serializes this summary to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': clazz.symbol,
      'constructor': constructor,
      'factory': factory,
    };
  }
}
