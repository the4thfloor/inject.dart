import 'dart:convert';

import 'package:inject_generator/src/build/codegen_builder.dart';
import 'package:inject_generator/src/source/lookup_key.dart';
import 'package:inject_generator/src/source/symbol_path.dart';
import 'package:quiver/testing/equality.dart';
import 'package:test/test.dart';

const String typeName1 = 'TypeName1';
const SymbolPath typeSymbolPath1 = SymbolPath.global(typeName1);

const String typeName2 = 'TypeName2';
const SymbolPath typeSymbolPath2 = SymbolPath.global(typeName2);

const String typeName3 = 'TypeName3';
const SymbolPath typeSymbolPath3 = SymbolPath.global(typeName3);

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

      test('only root with typeArguments', () {
        const type = LookupKey(
          typeSymbolPath1,
          typeArguments: [typeSymbolPath2, typeSymbolPath3],
        );

        final prettyString = type.toPrettyString();

        expect(prettyString, '$typeName1<$typeName2, $typeName3>');
      });

      test('qualified type with typeArguments', () {
        const type = LookupKey(
          typeSymbolPath1,
          qualifier: qualifier,
          typeArguments: [typeSymbolPath2, typeSymbolPath3],
        );

        final prettyString = type.toPrettyString();

        expect(prettyString, '$qualifierName@$typeName1<$typeName2, $typeName3>');
      });

      test('qualified type', () {
        const type = LookupKey(typeSymbolPath1, qualifier: qualifier);

        final prettyString = type.toPrettyString();

        expect(prettyString, '$qualifierName@$typeName1');
      });
    });

    group('toClassName', () {
      test('only root', () {
        const type = LookupKey(typeSymbolPath1);

        final prettyString = type.toPrettyString();

        expect(prettyString, typeName1);
      });

      test('only root with typeArguments', () {
        const type = LookupKey(
          typeSymbolPath1,
          typeArguments: [typeSymbolPath2, typeSymbolPath3],
        );

        final className = type.toClassName();

        expect(className, '$typeName1$typeName2$typeName3');
      });

      test('qualified type with typeArguments', () {
        const type = LookupKey(
          typeSymbolPath1,
          qualifier: qualifier,
          typeArguments: [typeSymbolPath2, typeSymbolPath3],
        );

        final className = type.toClassName();

        expect(className, '$typeName1${qualifierName.capitalize()}$typeName2$typeName3');
      });

      test('qualified type', () {
        const type = LookupKey(typeSymbolPath1, qualifier: qualifier);

        final className = type.toClassName();

        expect(className, '$typeName1${qualifierName.capitalize()}');
      });
    });

    group('serialization', () {
      test('with all fields', () {
        const type = LookupKey(
          typeSymbolPath1,
          qualifier: qualifier,
          typeArguments: [typeSymbolPath2, typeSymbolPath3],
        );

        final deserialized = deserialize(type);

        expect(deserialized, type);
      });

      test('without qualifier', () {
        const type = LookupKey(
          typeSymbolPath1,
          typeArguments: [typeSymbolPath2, typeSymbolPath3],
        );

        final deserialized = deserialize(type);

        expect(deserialized, type);
      });
    });

    test('equality', () {
      expect(
        {
          'only root': [
            const LookupKey(typeSymbolPath1),
            const LookupKey(typeSymbolPath1),
          ],
          'only root with typeArguments': [
            const LookupKey(
              typeSymbolPath1,
              typeArguments: [typeSymbolPath2, typeSymbolPath3],
            ),
            const LookupKey(
              typeSymbolPath1,
              typeArguments: [typeSymbolPath2, typeSymbolPath3],
            ),
          ],
          'qualified type with typeArguments': [
            const LookupKey(
              typeSymbolPath1,
              qualifier: qualifier,
              typeArguments: [typeSymbolPath2, typeSymbolPath3],
            ),
            const LookupKey(
              typeSymbolPath1,
              qualifier: qualifier,
              typeArguments: [typeSymbolPath2, typeSymbolPath3],
            ),
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
