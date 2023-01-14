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
      final stb = SummaryTestBed(inputAssetId: testAssetId);
      await stb.run();
      stb.printLog();

      expect(stb.logRecords.length, 1);

      final summaries = stb.summaries;
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

      final asset = stb.content.entries.first;
      final ctb = CodegenTestBed(inputAssetId: asset.key, input: asset.value);
      await ctb.run();
      await ctb.compare();
    });

    test('component with module', () async {
      const testFilePath = 'test/source/data/component_with_module.dart';
      final testAssetId = AssetId(rootPackage, testFilePath);
      final stb = SummaryTestBed(inputAssetId: testAssetId);
      await stb.run();
      stb.printLog();

      expect(stb.logRecords.length, 1);

      final summaries = stb.summaries;
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

      final asset = stb.content.entries.first;
      final ctb = CodegenTestBed(inputAssetId: asset.key, input: asset.value);
      await ctb.run();
      await ctb.compare();
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

    test('class with named parameter', () async {
      const testFilePath = 'test/source/data/class_with_named_parameter.dart';
      final testAssetId = AssetId(rootPackage, testFilePath);
      final stb = SummaryTestBed(inputAssetId: testAssetId);
      await stb.run();
      stb.printLog();

      expect(stb.logRecords.length, 1);

      final summaries = stb.summaries;
      expect(summaries.length, 1);

      final summary = summaries.values.first;
      expect(summary, isNotNull);
      expect(summary.assetUri, testAssetId.uri);

      expect(summary.components[0].providers.length, 1);
      expect(summary.components[0].providers[0].name, 'fooBar');
      expect(
        summary.components[0].providers[0].injectedType.lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'FooBar'),
      );

      expect(summary.injectables.length, 3);
      expect(
        summary.injectables[2].clazz,
        SymbolPath(rootPackage, testFilePath, 'FooBar'),
      );

      expect(summary.injectables[2].constructor.dependencies.length, 2);

      expect(
        summary.injectables[2].constructor.dependencies[0].lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Foo'),
      );
      expect(summary.injectables[2].constructor.dependencies[0].name, isNull);

      expect(
        summary.injectables[2].constructor.dependencies[1].lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Bar'),
      );
      expect(summary.injectables[2].constructor.dependencies[1].name, 'bar');

      final asset = stb.content.entries.first;
      final ctb = CodegenTestBed(inputAssetId: asset.key, input: asset.value);
      await ctb.run();
      await ctb.compare();
    });

    test('module method with named parameter', () async {
      const testFilePath =
          'test/source/data/module_method_with_named_parameter.dart';
      final testAssetId = AssetId(rootPackage, testFilePath);
      final stb = SummaryTestBed(inputAssetId: testAssetId);
      await stb.run();
      stb.printLog();

      expect(stb.logRecords.length, 1);

      final summaries = stb.summaries;
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

      expect(summary.injectables.length, 2);
      expect(
        summary.injectables[0].clazz,
        SymbolPath(rootPackage, testFilePath, 'Foo'),
      );
      expect(
        summary.injectables[1].clazz,
        SymbolPath(rootPackage, testFilePath, 'Bar'),
      );

      expect(summary.modules.length, 1);
      expect(
        summary.modules[0].clazz,
        SymbolPath(rootPackage, testFilePath, 'BarModule'),
      );

      expect(summary.modules[0].providers.length, 1);
      expect(summary.modules[0].providers[0].dependencies.length, 1);
      expect(summary.modules[0].providers[0].dependencies[0].name, 'foo');
      expect(
        summary.modules[0].providers[0].dependencies[0].lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Foo'),
      );

      final asset = stb.content.entries.first;
      final ctb = CodegenTestBed(inputAssetId: asset.key, input: asset.value);
      await ctb.run();
      await ctb.compare();
    });
  });
}
