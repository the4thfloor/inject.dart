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

      final summaries = stb.summaries;
      expect(summaries.length, 1);

      final summary = summaries.values.first;
      expect(summary, isNotNull);
      expect(summary.assetUri, testAssetId.uri);

      expect(summary.components.length, 1);
      final component = summary.components[0];

      expect(
        component.clazz,
        SymbolPath(rootPackage, testFilePath, 'ComponentWithoutModule'),
      );
      expect(component.providers.length, 1);
      expect(component.providers[0].name, 'getBar');
      expect(
        component.providers[0].injectedType.lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Bar'),
      );

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

      final summaries = stb.summaries;
      expect(summaries.length, 1);

      final summary = summaries.values.first;
      expect(summary, isNotNull);
      expect(summary.assetUri, testAssetId.uri);

      expect(summary.components.length, 1);
      final component = summary.components[0];

      expect(
        component.clazz,
        SymbolPath(rootPackage, testFilePath, 'ComponentWithModule'),
      );
      expect(component.providers.length, 1);
      expect(component.providers[0].name, 'bar');
      expect(
        component.providers[0].injectedType.lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Bar'),
      );

      expect(summary.injectables.length, 0);

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
          'component class must declare at least one @inject-annotated provider',
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
          'module class must declare at least one @provides-annotated provider',
        );
    });

    test('module method with async provider', () async {
      const testFilePath =
          'test/source/data/module_method_with_async_provider.dart';
      final testAssetId = AssetId(rootPackage, testFilePath);
      final stb = SummaryTestBed(inputAssetId: testAssetId);
      await stb.run();
      stb.printLog();

      final summaries = stb.summaries;
      expect(summaries.length, 1);

      final summary = summaries.values.first;
      expect(summary, isNotNull);
      expect(summary.assetUri, testAssetId.uri);
      expect(summary.modules.length, 1);

      final module = summary.modules[0];
      expect(
        module.clazz,
        SymbolPath(rootPackage, testFilePath, 'BarModule'),
      );
      expect(module.providers.length, 1);
      expect(module.providers[0].isAsynchronous, true);
      expect(
        module.providers[0].injectedType.lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Bar'),
      );

      final asset = stb.content.entries.first;
      final ctb = CodegenTestBed(inputAssetId: asset.key, input: asset.value);
      await ctb.run();
      await ctb.compare();
    });

    test('singleton inject', () async {
      const testFilePath = 'test/source/data/singleton_inject.dart';
      final testAssetId = AssetId(rootPackage, testFilePath);
      final stb = SummaryTestBed(inputAssetId: testAssetId);
      await stb.run();
      stb.printLog();

      final summaries = stb.summaries;
      expect(summaries.length, 1);

      final summary = summaries.values.first;
      expect(summary, isNotNull);
      expect(summary.assetUri, testAssetId.uri);
      expect(summary.modules.length, 1);

      final module = summary.modules[0];
      expect(
        module.clazz,
        SymbolPath(rootPackage, testFilePath, 'BarModule'),
      );
      expect(module.providers.length, 1);
      expect(module.providers[0].isSingleton, true);
      expect(
        module.providers[0].injectedType.lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Bar'),
      );

      expect(summary.injectables.length, 2);
      final injectable0 = summary.injectables[0];
      final injectable1 = summary.injectables[1];

      expect(injectable0.clazz, SymbolPath(rootPackage, testFilePath, 'Foo'));
      expect(injectable0.constructor.isSingleton, true);

      expect(injectable1.clazz, SymbolPath(rootPackage, testFilePath, 'Foo2'));
      expect(injectable1.constructor.isSingleton, true);

      final asset = stb.content.entries.first;
      final ctb = CodegenTestBed(inputAssetId: asset.key, input: asset.value);
      await ctb.run();
      await ctb.compare();
    });

    test('assisted inject', () async {
      const testFilePath = 'test/source/data/assisted_inject.dart';
      final testAssetId = AssetId(rootPackage, testFilePath);
      final stb = SummaryTestBed(inputAssetId: testAssetId);
      await stb.run();
      stb.printLog();

      final summaries = stb.summaries;
      expect(summaries.length, 1);

      final summary = summaries.values.first;
      expect(summary, isNotNull);
      expect(summary.assetUri, testAssetId.uri);
      expect(summary.components.length, 1);

      final component = summary.components[0];
      expect(
        component.clazz,
        SymbolPath(rootPackage, testFilePath, 'Component'),
      );
      expect(component.providers.length, 2);
      expect(component.providers[0].name, 'annotatedClassFactory');
      expect(
        component.providers[0].injectedType.lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'AnnotatedClassFactory'),
      );
      expect(component.providers[1].name, 'annotatedConstructorFactory');
      expect(
        component.providers[1].injectedType.lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'AnnotatedConstructorFactory'),
      );

      /////

      expect(summary.injectables.length, 3);
      final annotatedClass = summary.injectables[0];
      final annotatedConstructor = summary.injectables[1];
      final foo = summary.injectables[2];

      expect(
        annotatedClass.clazz,
        SymbolPath(rootPackage, testFilePath, 'AnnotatedClass'),
      );
      expect(
        annotatedClass.factory!.root,
        SymbolPath(rootPackage, testFilePath, 'AnnotatedClassFactory'),
      );
      expect(annotatedClass.constructor.dependencies.length, 2);
      expect(
        annotatedClass.constructor.dependencies[0].lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Foo'),
      );
      expect(
        annotatedClass.constructor.dependencies[0].isAssisted,
        false,
      );
      expect(
        annotatedClass.constructor.dependencies[1].lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Bar'),
      );
      expect(
        annotatedClass.constructor.dependencies[1].isAssisted,
        true,
      );

      expect(
        annotatedConstructor.clazz,
        SymbolPath(rootPackage, testFilePath, 'AnnotatedConstructor'),
      );
      expect(
        annotatedConstructor.factory!.root,
        SymbolPath(rootPackage, testFilePath, 'AnnotatedConstructorFactory'),
      );
      expect(annotatedConstructor.constructor.dependencies.length, 2);
      expect(
        annotatedConstructor.constructor.dependencies[0].lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Foo'),
      );
      expect(
        annotatedConstructor.constructor.dependencies[0].isAssisted,
        false,
      );
      expect(
        annotatedConstructor.constructor.dependencies[1].lookupKey.root,
        SymbolPath(rootPackage, testFilePath, 'Bar'),
      );
      expect(
        annotatedConstructor.constructor.dependencies[1].isAssisted,
        true,
      );

      expect(foo.clazz, SymbolPath(rootPackage, testFilePath, 'Foo'));
      expect(foo.factory, isNull);

      expect(summary.factories.length, 2);
      expect(
        summary.factories[0].clazz,
        SymbolPath(rootPackage, testFilePath, 'AnnotatedClassFactory'),
      );
      expect(
        summary.factories[1].clazz,
        SymbolPath(rootPackage, testFilePath, 'AnnotatedConstructorFactory'),
      );

      final asset = stb.content.entries.first;
      final ctb = CodegenTestBed(inputAssetId: asset.key, input: asset.value);
      await ctb.run();
      await ctb.compare();
    });
  });
}
