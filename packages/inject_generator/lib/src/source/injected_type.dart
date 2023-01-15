// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'lookup_key.dart';

/// A type that the user is trying to inject with associated metadata about how
/// the user is trying to inject it.
class InjectedType {
  /// The type the user is trying to inject.
  final LookupKey lookupKey;

  /// Name of the parameter.
  final String? name;

  /// Return `true` if this parameter is required.
  final bool isRequired;

  /// Return `true` if it is a named parameter. Otherwise `false` for a positional parameter.
  final bool isNamed;

  /// True if the user is trying to inject [LookupKey] using a function type. If
  /// false, the user is trying to inject the type directly.
  final bool isProvider;

  /// True if the user is trying to inject [LookupKey] with a Feature.
  /// If false, the user is trying to inject the type directly.
  final bool isFeature;

  /// True if the user wants to inject it manually via assisted inject.
  final bool isAssisted;

  factory InjectedType(
    LookupKey lookupKey, {
    String? name,
    bool? isRequired,
    bool? isNamed,
    bool? isProvider,
    bool? isFeature,
    bool? isAssisted,
  }) =>
      InjectedType._(
        lookupKey,
        name,
        isRequired ?? false,
        isNamed ?? false,
        isProvider ?? false,
        isFeature ?? false,
        isAssisted ?? false,
      );

  const InjectedType._(
    this.lookupKey,
    this.name,
    this.isRequired,
    this.isNamed,
    this.isProvider,
    this.isFeature,
    this.isAssisted,
  );

  /// Returns a new instance from the JSON encoding of an instance.
  ///
  /// See also [InjectedType.toJson].
  factory InjectedType.fromJson(Map<String, dynamic> json) {
    return InjectedType(
      LookupKey.fromJson(json['lookupKey']),
      name: json['name'],
      isRequired: json['isRequired'],
      isNamed: json['isNamed'],
      isProvider: json['isProvider'],
      isFeature: json['isFeature'],
      isAssisted: json['isAssisted'],
    );
  }

  /// Returns the JSON encoding of this instance.
  ///
  /// See also [InjectedType.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'lookupKey': lookupKey.toJson(),
      'name': name,
      'isRequired': isRequired,
      'isNamed': isNamed,
      'isProvider': isProvider,
      'isFeature': isFeature,
      'isAssisted': isAssisted,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InjectedType &&
          runtimeType == other.runtimeType &&
          lookupKey == other.lookupKey &&
          name == other.name &&
          isRequired == other.isRequired &&
          isNamed == other.isNamed &&
          isProvider == other.isProvider &&
          isFeature == other.isFeature &&
          isAssisted == other.isAssisted;

  @override
  int get hashCode =>
      lookupKey.hashCode ^
      name.hashCode ^
      isRequired.hashCode ^
      isNamed.hashCode ^
      isProvider.hashCode ^
      isFeature.hashCode ^
      isAssisted.hashCode;
}
