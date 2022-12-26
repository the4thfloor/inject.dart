import 'package:inject_generator/src/source/symbol_path.dart';
import 'package:test/test.dart';

void main() {
  group('$SymbolPath', () {
    group('should prevent construction when', () {
      void assertThrowsArgumentError({
        String package = 'test',
        String path = 'test.dart',
        String symbol = 'Test',
      }) {
        expect(
          () => SymbolPath(package, path, symbol),
          throwsArgumentError,
        );
      }

      test('package is empty', () {
        assertThrowsArgumentError(package: '');
      });

      test('path does not end with ".dart"', () {
        assertThrowsArgumentError(path: 'test');
      });

      test('path is empty when the package is "dart"', () {
        assertThrowsArgumentError(package: 'dart', path: '');
      });

      test('symbol is empty', () {
        assertThrowsArgumentError(symbol: '');
      });
    });

    test('should set the package as "dart" with the dartSdk factory', () {
      expect(
        SymbolPath.dartSdk('core', 'List'),
        SymbolPath('dart', 'core', 'List'),
      );
    });

    test('should generate a valid asset URI for a Dart package', () {
      expect(
        SymbolPath('collection', 'lib/collection.dart', 'MapEquality')
            .toAbsoluteUri()
            .toString(),
        'asset:collection/lib/collection.dart#MapEquality',
      );
    });

    test('should generate a valid asset URI for a Dart SDK package', () {
      expect(
        SymbolPath.dartSdk('core', 'List').toAbsoluteUri().toString(),
        'dart:core#List',
      );
    });

    test('should generate a valid import URI for a Dart SDK package', () {
      expect(
        SymbolPath.dartSdk('core', 'DateTime').toDartUri().toString(),
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
