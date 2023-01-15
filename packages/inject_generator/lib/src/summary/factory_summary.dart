// Copyright (c) 2023 by Ralph Bergmann. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of inject.src.summary;

/// Result of analyzing a `@AssistedFactory()` annotated-class.
class FactorySummary {
  /// Location of the analyzed class.
  final SymbolPath clazz;

  /// The factory method.
  final FactoryMethodSummary factory;

  /// Create a new summary of a AssistedInject factory [clazz].
  const FactorySummary(this.clazz, this.factory);

  /// Returns a new instance from the JSON encoding of an instance.
  ///
  /// See also [FactorySummary.toJson].
  factory FactorySummary.fromJson(Uri assetUri, Map<String, dynamic> json) {
    final name = json['name'] as String;
    final factory = FactoryMethodSummary.fromJson(json['factory']);
    final clazz = SymbolPath.fromAbsoluteUri(assetUri, name);
    return FactorySummary(clazz, factory);
  }

  /// Serializes this summary to JSON.
  Map<String, dynamic> toJson() {
    return {'name': clazz.symbol, 'factory': factory};
  }
}

/// Contains information about a AssistedInject factory method.
class FactoryMethodSummary {
  /// Name of the annotated method.
  final String name;

  /// Type of the instance that will be created.
  final InjectedType createdType;

  /// Manually injected parameters to create an instance of [createdType].
  /// These are the @assisted-annotated constructor parameters of [createdType].
  final List<InjectedType> parameters;

  const FactoryMethodSummary(this.name, this.createdType, this.parameters);

  /// Returns a new instance from the JSON encoding of an instance.
  ///
  /// See also [FactorySummary.toJson].
  factory FactoryMethodSummary.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String;
    final injectedType = InjectedType.fromJson(json['createdType']);
    final parameters = json['parameters']
        .cast<Map<String, dynamic>>()
        .map<InjectedType>(InjectedType.fromJson)
        .toList();
    return FactoryMethodSummary(name, injectedType, parameters);
  }

  /// Serializes this summary to JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'createdType': createdType,
      'parameters': parameters,
    };
  }
}
