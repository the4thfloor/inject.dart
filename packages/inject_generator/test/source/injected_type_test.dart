import 'dart:convert';

import 'package:inject_generator/src/source/injected_type.dart';
import 'package:inject_generator/src/source/lookup_key.dart';
import 'package:inject_generator/src/source/symbol_path.dart';
import 'package:quiver/testing/equality.dart';
import 'package:test/test.dart';

const LookupKey lookupKey1 = LookupKey(SymbolPath.global('1'));
const LookupKey lookupKey2 = LookupKey(SymbolPath.global('2'));

void main() {
  group(LookupKey, () {
    test('serialization', () {
      final type = InjectedType(lookupKey1, isProvider: true);

      final deserialized = deserialize(type);

      expect(deserialized, type);
    });

    test('equality', () {
      expect(
        {
          'only lookupKey': [InjectedType(lookupKey1), InjectedType(lookupKey1)],
          'different lookupKey': [InjectedType(lookupKey2), InjectedType(lookupKey2)],
          'with isProvider': [InjectedType(lookupKey1, isProvider: true), InjectedType(lookupKey1, isProvider: true)],
        },
        areEqualityGroups,
      );
    });
  });
}

InjectedType deserialize(InjectedType type) {
  final json = const JsonEncoder().convert(type);
  return InjectedType.fromJson(const JsonDecoder().convert(json));
}
