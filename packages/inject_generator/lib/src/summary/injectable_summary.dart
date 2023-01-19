// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of inject.src.summary;

/// Result of analyzing a class whose constructor is annotated with `@Provide()`.
class InjectableSummary {
  /// Location of the analyzed class.
  final SymbolPath clazz;

  /// Summary about the constructor annotated with `@Provide()`.
  final ProviderSummary constructor;

  /// Constructor.
  ///
  /// [clazz] is the path to the injectable class. [constructor] carries summary
  /// about the constructor annotated with `@Provide()`.
  factory InjectableSummary(SymbolPath clazz, ProviderSummary constructor) {
    return InjectableSummary._(clazz, constructor);
  }

  const InjectableSummary._(this.clazz, this.constructor);

  /// Returns a new instance from the JSON encoding of an instance.
  ///
  /// See also [InjectableSummary.toJson].
  factory InjectableSummary.fromJson(Uri assetUri, Map<String, dynamic> json) {
    final name = json['name'] as String;
    final type = SymbolPath.fromAbsoluteUri(assetUri, name);
    return InjectableSummary(
      type,
      ProviderSummary.fromJson(json['constructor'].cast<String, dynamic>()),
    );
  }

  /// Serializes this summary to JSON.
  Map<String, dynamic> toJson() {
    return {'name': clazz.symbol, 'constructor': constructor};
  }
}
