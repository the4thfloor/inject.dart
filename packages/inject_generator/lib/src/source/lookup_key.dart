// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';

import '../analyzer/utils.dart';
import '../build/codegen_builder.dart';
import 'symbol_path.dart';

/// A representation of a key in the dependency injection graph.
///
/// Equality of all the fields indicate that two types are the same.
class LookupKey {
  /// [SymbolPath] of the root type.
  ///
  /// For example, for the type `@qualifier A<B, C>`, this will be `A`.
  final SymbolPath root;

  /// Return `true` if the type is nullable.
  final bool isNullable;

  /// Optional qualifier for the type.
  final SymbolPath? qualifier;

  const LookupKey(this.root, {this.isNullable = false, this.qualifier});

  /// Returns a new instance from the JSON encoding of an instance.
  ///
  /// See also [LookupKey.toJson].
  factory LookupKey.fromJson(Map<String, dynamic> json) {
    return LookupKey(
      SymbolPath.fromAbsoluteUri(Uri.parse(json['root'])),
      isNullable: json['isNullable'],
      qualifier: json['qualifier'] == null
          ? null
          : SymbolPath.fromAbsoluteUri(Uri.parse(json['qualifier'])),
    );
  }

  factory LookupKey.fromDartType(DartType type, {SymbolPath? qualifier}) =>
      LookupKey(
        getSymbolPath(type.element!),
        isNullable: type.isNullable(),
        qualifier: qualifier,
      );

  /// A human-readable representation of the dart Symbol of this type.
  String toPrettyString() {
    final qualifierString = qualifier != null ? '${qualifier!.symbol}@' : '';
    final nullableString = isNullable ? '?' : '';
    return '$qualifierString${root.symbol}$nullableString';
  }

  String toClassName() {
    final qualifierString = qualifier != null ? qualifier!.symbol : '';
    return '${root.symbol}${qualifierString.capitalize()}';
  }

  /// Returns the JSON encoding of this instance.
  ///
  /// See also [LookupKey.fromJson].
  Map<String, dynamic> toJson() {
    return {
      'root': root.toAbsoluteUri().toString(),
      'isNullable': isNullable,
      'qualifier': qualifier?.toAbsoluteUri().toString(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LookupKey &&
          runtimeType == other.runtimeType &&
          root == other.root &&
          qualifier == other.qualifier;

  @override
  int get hashCode => root.hashCode ^ qualifier.hashCode;
}
