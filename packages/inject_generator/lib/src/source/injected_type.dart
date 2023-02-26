// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:json_annotation/json_annotation.dart';

import 'lookup_key.dart';

part 'injected_type.g.dart';

/// A type that the user is trying to inject with associated metadata about how
/// the user is trying to inject it.
@JsonSerializable()
class InjectedType {
  /// The type the user is trying to inject.
  final LookupKey lookupKey;

  /// Name of the parameter.
  final String? name;

  /// Return `true` if this parameter is nullable.
  final bool isNullable;

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
    bool? isNullable,
    bool? isRequired,
    bool? isNamed,
    bool? isProvider,
    bool? isFeature,
    bool? isAssisted,
  }) =>
      InjectedType._(
        lookupKey,
        name,
        isNullable ?? false,
        isRequired ?? false,
        isNamed ?? false,
        isProvider ?? false,
        isFeature ?? false,
        isAssisted ?? false,
      );

  const InjectedType._(
    this.lookupKey,
    this.name,
    this.isNullable,
    this.isRequired,
    this.isNamed,
    this.isProvider,
    this.isFeature,
    this.isAssisted,
  );

  factory InjectedType.fromJson(Map<String, dynamic> json) =>
      _$InjectedTypeFromJson(json);

  Map<String, dynamic> toJson() => _$InjectedTypeToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InjectedType &&
          runtimeType == other.runtimeType &&
          lookupKey == other.lookupKey &&
          name == other.name &&
          isNullable == other.isNullable &&
          isRequired == other.isRequired &&
          isNamed == other.isNamed &&
          isProvider == other.isProvider &&
          isFeature == other.isFeature &&
          isAssisted == other.isAssisted;

  @override
  int get hashCode =>
      lookupKey.hashCode ^
      name.hashCode ^
      isNullable.hashCode ^
      isRequired.hashCode ^
      isNamed.hashCode ^
      isProvider.hashCode ^
      isFeature.hashCode ^
      isAssisted.hashCode;

  @override
  String toString() {
    return 'InjectedType{lookupKey: ${lookupKey.toClassName()}, name: $name, isNullable: $isNullable}';
  }
}
