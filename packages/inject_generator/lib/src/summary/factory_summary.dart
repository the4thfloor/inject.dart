// Copyright (c) 2023 by Ralph Bergmann. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of '../summary.dart';

/// Result of analyzing a `@AssistedFactory()` annotated-class.
@JsonSerializable()
class FactorySummary {
  /// Location of the analyzed class.
  final SymbolPath clazz;

  /// The factory method.
  final FactoryMethodSummary factory;

  /// Create a new summary of a AssistedInject factory [clazz].
  const FactorySummary(this.clazz, this.factory);

  factory FactorySummary.fromJson(Map<String, dynamic> json) => _$FactorySummaryFromJson(json);

  Map<String, dynamic> toJson() => _$FactorySummaryToJson(this);
}

/// Contains information about a AssistedInject factory method.
@JsonSerializable()
class FactoryMethodSummary {
  /// Name of the annotated method.
  final String name;

  /// Type of the instance that will be created.
  final InjectedType createdType;

  /// Manually injected parameters to create an instance of [createdType].
  /// These are the @assisted-annotated constructor parameters of [createdType].
  final List<InjectedType> parameters;

  const FactoryMethodSummary(this.name, this.createdType, this.parameters);

  factory FactoryMethodSummary.fromJson(Map<String, dynamic> json) => _$FactoryMethodSummaryFromJson(json);

  Map<String, dynamic> toJson() => _$FactoryMethodSummaryToJson(this);
}
