import 'package:build/build.dart';
import 'package:inject_generator/src/source/symbol_path.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

import '../utils.dart';

void main() {
  group('annotations test', () {
    test('component without module', () async {
      const testFilePath = 'test/source/data/component_without_module.dart';
      final testAssetId = AssetId(rootPackage, testFilePath);
      final tb = SummaryTestBed(inputAssetId: testAssetId);
      await tb.run();
      tb.printLog();

      expect(tb.logRecords.length, 1);

      final summaries = tb.summaries;
      expect(summaries.length, 1);

      final summary = summaries.values.first;
      expect(summary, isNotNull);
      expect(summary.assetUri, testAssetId.uri);

      expect(summary.components.length, 1);
      expect(
        summary.components[0].clazz,
        SymbolPath(rootPackage, testFilePath, 'ComponentWithoutModule'),
      );
      expect(summary.components[0].providers.length, 1);
      expect(summary.components[0].providers[0].name, 'getBar');
      expect(
        summary.components[0].providers[0].injectedType.lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Bar'),
      );
      expect(summary.components[0].providers[0].injectedType.isProvider, false);

      expect(summary.injectables.length, 2);
      expect(
        summary.injectables[0].clazz,
        SymbolPath(rootPackage, testFilePath, 'Bar'),
      );
      expect(
        summary.injectables[1].clazz,
        SymbolPath(rootPackage, testFilePath, 'Foo'),
      );
    });

    test('component with module', () async {
      const testFilePath = 'test/source/data/component_with_module.dart';
      final testAssetId = AssetId(rootPackage, testFilePath);
      final tb = SummaryTestBed(inputAssetId: testAssetId);
      await tb.run();
      tb.printLog();

      expect(tb.logRecords.length, 1);

      final summaries = tb.summaries;
      expect(summaries.length, 1);

      final summary = summaries.values.first;
      expect(summary, isNotNull);
      expect(summary.assetUri, testAssetId.uri);

      expect(summary.components.length, 1);
      expect(
        summary.components[0].clazz,
        SymbolPath(rootPackage, testFilePath, 'ComponentWithModule'),
      );
      expect(summary.components[0].providers.length, 1);
      expect(summary.components[0].providers[0].name, 'bar');
      expect(
        summary.components[0].providers[0].injectedType.lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Bar'),
      );
      expect(summary.components[0].providers[0].injectedType.isProvider, false);

      expect(summary.injectables.length, 1);
      expect(
        summary.injectables[0].clazz,
        SymbolPath(rootPackage, testFilePath, 'Bar'),
      );
    });

    test('component with @provides', () async {
      const testFilePath = 'test/source/data/component_with_provides.dart';
      final testAssetId = AssetId(rootPackage, testFilePath);
      final tb = SummaryTestBed(inputAssetId: testAssetId);
      await tb.run();

      tb
        ..printLog()
        ..expectLogRecord(
          Level.WARNING,
          '@provides annotation is not supported for components',
        )
        ..expectLogRecord(
          Level.SEVERE,
          'component class must declare at least one provider',
        );
    });

    test('module with @inject', () async {
      const testFilePath = 'test/source/data/module_with_inject.dart';
      final testAssetId = AssetId(rootPackage, testFilePath);
      final tb = SummaryTestBed(inputAssetId: testAssetId);
      await tb.run();

      tb
        ..printLog()
        ..expectLogRecord(
          Level.WARNING,
          '@inject annotation is not supported for modules',
        )
        ..expectLogRecord(
          Level.SEVERE,
          'module class must declare at least one provider',
        );
    });
  });
}
