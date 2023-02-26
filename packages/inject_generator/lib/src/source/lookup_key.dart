// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:json_annotation/json_annotation.dart';

import '../analyzer/utils.dart';
import '../build/codegen_builder.dart';
import 'symbol_path.dart';

part 'lookup_key.g.dart';

const _listEquality = ListEquality();

/// A representation of a key in the dependency injection graph.
///
/// Equality of all the fields indicate that two types are the same.///
@JsonSerializable()
class LookupKey {
  /// [SymbolPath] of the root type.
  ///
  /// For example, for the type `@qualifier A<B, C>`, this will be `A`.
  final SymbolPath root;

  /// Optional qualifier for the type.
  final SymbolPath? qualifier;

  final List<SymbolPath>? typeArguments;

  const LookupKey(this.root, {this.qualifier, this.typeArguments});

  factory LookupKey.fromJson(Map<String, dynamic> json) =>
      _$LookupKeyFromJson(json);

  factory LookupKey.fromDartType(DartType type, {SymbolPath? qualifier}) =>
      LookupKey(
        getSymbolPath(type),
        qualifier: qualifier,
        typeArguments:
            type is ParameterizedType && type.typeArguments.isNotEmpty
                ? type.typeArguments
                    .map((typeArgument) => getSymbolPath(typeArgument))
                    .toList()
                : null,
      );

  /// A human-readable representation of the dart Symbol of this type.
  String toPrettyString() {
    final qualifierString = qualifier != null ? '${qualifier!.symbol}@' : '';
    final typeArgumentsString = typeArguments?.isNotEmpty == true
        ? "<${typeArguments?.map((e) => e.symbol).join(', ')}>"
        : '';
    return '$qualifierString${root.symbol}$typeArgumentsString';
  }

  String toClassName() {
    final qualifierString = qualifier != null ? qualifier!.symbol : '';
    final typeArgumentsString =
        typeArguments?.map((e) => e.symbol).join() ?? '';
    return '${root.symbol}${qualifierString.capitalize()}$typeArgumentsString';
  }

  Map<String, dynamic> toJson() => _$LookupKeyToJson(this);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LookupKey &&
          runtimeType == other.runtimeType &&
          root == other.root &&
          qualifier == other.qualifier &&
          _listEquality.equals(typeArguments, other.typeArguments);

  @override
  int get hashCode =>
      root.hashCode ^ qualifier.hashCode ^ _listEquality.hash(typeArguments);
}
