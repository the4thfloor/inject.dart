import 'package:inject_generator/src/source/symbol_path.dart';
import 'package:test/test.dart';

void main() {
  group('$SymbolPath', () {
    test('should set the package as "dart" with the dartSdk factory', () {
      expect(
        const SymbolPath.dartSdk('core', 'List'),
        const SymbolPath('dart', 'core', 'List'),
      );
    });

    test('should generate a valid asset URI for a Dart package', () {
      expect(
        const SymbolPath('collection', 'lib/collection.dart', 'MapEquality')
            .toAbsoluteUri()
            .toString(),
        'asset:collection/lib/collection.dart#MapEquality',
      );
    });

    test('should generate a valid asset URI for a Dart SDK package', () {
      expect(
        const SymbolPath.dartSdk('core', 'List').toAbsoluteUri().toString(),
        'dart:core#List',
      );
    });

    test('should generate a valid import URI for a Dart SDK package', () {
      expect(
        const SymbolPath.dartSdk('core', 'DateTime').toDartUri().toString(),
        'dart:core',
      );
    });

    test('should generate a valid asset URI for a global symbol', () {
      expect(
        const SymbolPath.global('baseUri').toAbsoluteUri().toString(),
        'global:#baseUri',
      );
    });
  });
}
