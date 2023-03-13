// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of inject.src.summary;

/// Result of analyzing a class whose constructor is annotated with `@Inject()`.
@JsonSerializable()
class InjectableSummary {
  /// Location of the analyzed class.
  final SymbolPath clazz;

  /// Summary about the constructor annotated with `@Inject()`.
  final ProviderSummary constructor;

  /// Constructor.
  ///
  /// [clazz] is the path to the injectable class. [constructor] carries summary
  /// about the constructor annotated with `@Inject()`.
  const InjectableSummary(this.clazz, this.constructor);

  factory InjectableSummary.fromJson(Map<String, dynamic> json) =>
      _$InjectableSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$InjectableSummaryToJson(this);
}
