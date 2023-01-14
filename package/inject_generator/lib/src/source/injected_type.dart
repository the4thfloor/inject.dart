// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:quiver/core.dart';

import 'lookup_key.dart';

/// A type that the user is trying to inject with associated metadata about how
/// the user is trying to inject it.
class InjectedType {
  /// The type the user is trying to inject.
  final LookupKey lookupKey;

  /// Name of the parameter if the user wants to inject it as a named paramter.
  final String? name;

  /// True if the user is trying to inject [LookupKey] using a function type. If
  /// false, the user is trying to inject the type directly.
  final bool isProvider;

  InjectedType(this.lookupKey, {this.name, this.isProvider = false});

  /// Returns a new instance from the JSON encoding of an instance.
  ///
  /// See also [InjectedType.toJson].
  factory InjectedType.fromJson(Map<String, dynamic> json) {
    return InjectedType(
      LookupKey.fromJson(json['lookupKey']),
      name: json['name'],
      isProvider: json['isProvider'],
    );
  }

  /// Returns the JSON encoding of this instance.
  ///
  /// See also [InjectedType.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'lookupKey': lookupKey.toJson(),
      'name': name,
      'isProvider': isProvider,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InjectedType &&
          runtimeType == other.runtimeType &&
          lookupKey == other.lookupKey &&
          name == other.name &&
          isProvider == other.isProvider;

  @override
  int get hashCode {
    // Not all fields are here. See the equals method doc for more info.
    return hash3(lookupKey, name, isProvider);
  }

  @override
  String toString() {
    return '$InjectedType{'
        'lookupKey: $lookupKey, '
        'name: $name, '
        'isProvider: $isProvider}';
  }
}
