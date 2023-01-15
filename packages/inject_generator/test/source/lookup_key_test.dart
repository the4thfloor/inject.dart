import 'dart:convert';

import 'package:inject_generator/src/source/lookup_key.dart';
import 'package:inject_generator/src/source/symbol_path.dart';
import 'package:quiver/testing/equality.dart';
import 'package:test/test.dart';

const String typeName1 = 'TypeName1';
const SymbolPath typeSymbolPath1 = SymbolPath.global(typeName1);

const String typeName2 = 'TypeName2';
const SymbolPath typeSymbolPath2 = SymbolPath.global(typeName2);

const String qualifierName = 'fakeQualifier';
const SymbolPath qualifier = SymbolPath.global(qualifierName);

void main() {
  group(LookupKey, () {
    group('toPrettyString', () {
      test('only root', () {
        const type = LookupKey(typeSymbolPath1);

        final prettyString = type.toPrettyString();

        expect(prettyString, typeName1);
      });

      test('qualified type', () {
        const type = LookupKey(typeSymbolPath1, qualifier: qualifier);

        final prettyString = type.toPrettyString();

        expect(prettyString, '$qualifierName@$typeName1');
      });
    });

    group('serialization', () {
      test('with all fields', () {
        const type = LookupKey(typeSymbolPath1, qualifier: qualifier);

        final deserialized = deserialize(type);

        expect(deserialized, type);
      });

      test('without qualifier', () {
        const type = LookupKey(typeSymbolPath1);

        final deserialized = deserialize(type);

        expect(deserialized, type);
      });
    });

    test('equality', () {
      expect(
        {
          'only root': [
            const LookupKey(typeSymbolPath1),
            const LookupKey(typeSymbolPath1)
          ],
          'with qualifier': [
            const LookupKey(typeSymbolPath1, qualifier: qualifier),
            const LookupKey(typeSymbolPath1, qualifier: qualifier)
          ],
        },
        areEqualityGroups,
      );
    });
  });
}

LookupKey deserialize(LookupKey type) {
  final json = const JsonEncoder().convert(type);
  return LookupKey.fromJson(const JsonDecoder().convert(json));
}
