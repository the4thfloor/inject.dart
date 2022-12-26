import 'dart:async';
import 'dart:io';

import 'package:inject_generator/src/graph.dart';
import 'package:inject_generator/src/source/injected_type.dart';
import 'package:inject_generator/src/source/lookup_key.dart';
import 'package:inject_generator/src/source/symbol_path.dart';
import 'package:inject_generator/src/summary.dart';
import 'package:quiver/testing/equality.dart';
import 'package:test/test.dart';

void main() {
  group(
    '$InjectorGraphResolver',
    () {
      FakeSummaryReader? reader;

      setUp(() {
        reader = FakeSummaryReader({
          'foo/foo.inject.summary': LibrarySummary(
            Uri.parse('asset:foo/foo.dart'),
            modules: [
              ModuleSummary(
                  SymbolPath.parseAbsoluteUri('asset:foo/foo.dart#FooModule'), [
                ProviderSummary(
                  InjectedType(
                    LookupKey(
                      SymbolPath.parseAbsoluteUri('asset:foo/foo.dart', 'Foo'),
                    ),
                  ),
                  'provideFoo',
                  ProviderKind.method,
                ),
              ]),
            ],
          )
        });
      });

      test('should correctly resolve an object graph', () async {
        final foo = InjectedType(
          LookupKey(SymbolPath.parseAbsoluteUri('asset:foo/foo.dart#Foo')),
        );
        final injectorSummary = InjectorSummary(
          SymbolPath('foo', 'foo.dart', 'FooInjector'),
          [SymbolPath.parseAbsoluteUri('asset:foo/foo.dart#FooModule')],
          [
            ProviderSummary(
              foo,
              'getFoo',
              ProviderKind.method,
            )
          ],
        );
        final resolver = InjectorGraphResolver(reader!, injectorSummary);
        final resolvedGraph = await resolver.resolve();

        expect(resolvedGraph.includeModules, hasLength(1));
        final fooModule = resolvedGraph.includeModules.first;
        expect(
          fooModule.toAbsoluteUri().toString(),
          'asset:foo/foo.dart#FooModule',
        );

        expect(resolvedGraph.providers, hasLength(1));
        final fooProvider = resolvedGraph.providers.first;
        expect(fooProvider.injectedType, foo);
        expect(fooProvider.methodName, 'getFoo');
      });

      test('should correctly resolve a qualifier in an object graph', () async {
        final qualifiedFoo = InjectedType(
          LookupKey(
            SymbolPath.parseAbsoluteUri('asset:foo/foo.dart', 'Foo'),
            qualifier: const SymbolPath.global('uniqueName'),
          ),
        );
        final injectorSummary = InjectorSummary(
          SymbolPath('foo', 'foo.dart', 'FooInjector'),
          [
            SymbolPath.parseAbsoluteUri('asset:foo/foo.dart#FooModule'),
          ],
          [
            ProviderSummary(
              qualifiedFoo,
              'provideName',
              ProviderKind.method,
            ),
          ],
        );
        final resolver = InjectorGraphResolver(reader!, injectorSummary);
        final resolvedGraph = await resolver.resolve();

        expect(resolvedGraph.includeModules, hasLength(1));
        final fooModule = resolvedGraph.includeModules.first;
        expect(
          fooModule.toAbsoluteUri().toString(),
          'asset:foo/foo.dart#FooModule',
        );
        expect(resolvedGraph.providers, hasLength(1));

        final nameProvider = resolvedGraph.providers.first;
        expect(
          nameProvider.injectedType,
          qualifiedFoo,
        );
        expect(nameProvider.methodName, 'provideName');
      });

      // test('should log a useful message when a summary is missing', () async {
      //   final ctx = _FakeBuilderContext();
      //   await runZoned(
      //     () async {
      //       final injectorSummary = InjectorSummary(
      //         SymbolPath('foo', 'foo.dart', 'FooInjector'),
      //         [],
      //         [
      //           ProviderSummary(
      //             InjectedType(
      //               LookupKey(
      //                 SymbolPath.parseAbsoluteUri('asset:foo/missing.dart#Foo'),
      //               ),
      //             ),
      //             'getFoo',
      //             ProviderKind.method,
      //           )
      //         ],
      //       );
      //       final resolver = InjectorGraphResolver(reader, injectorSummary);
      //       await resolver.resolve();
      //     },
      //     zoneValues: {#builderContext: ctx},
      //   );
      //   expect(
      //     ctx.records.any(
      //       (r) =>
      //           r.level == Level.SEVERE &&
      //           r.message.contains(
      //             'Unable to locate metadata about Foo defined in asset:foo/missing.dart',
      //           ) &&
      //           r.message.contains(
      //             'This dependency is requested by FooInjector defined in asset:foo/foo.dart.',
      //           ),
      //     ),
      //     isTrue,
      //   );
      // });
    },
    // skip: 'Currently not working with the external build system',
  );

  group('$Cycle', () {
    test('has order-independent hashCode and operator==', () {
      final sA = LookupKey(SymbolPath('package', 'path.dart', 'A'));
      final sB = LookupKey(SymbolPath('package', 'path.dart', 'B'));
      final sC = LookupKey(SymbolPath('package', 'path.dart', 'C'));
      final sD = LookupKey(SymbolPath('package', 'path.dart', 'D'));

      final cycle1 = Cycle([sA, sB, sC, sA]);
      final cycle2 = Cycle([sB, sC, sA, sB]);
      final cycle3 = Cycle([sC, sA, sB, sC]);

      final diffNodes1 = Cycle([sA, sB, sA]);
      final diffNodes2 = Cycle([sA, sB, sC, sD, sA]);

      final diffEdges = Cycle([sA, sC, sB, sA]);

      expect(
        {
          'base': [cycle1, cycle2, cycle3],
          'different node': [diffNodes1],
          'another different node': [diffNodes2],
          'different edges': [diffEdges],
        },
        areEqualityGroups,
      );
    });
  });
}

// class _FakeBuilderContext implements BuilderContext {
//   final List<LogRecord> records = <LogRecord>[];
//
//   @override
//   final Logger rawLogger = Logger('_FakeBuilderContextLogger');
//
//   _FakeBuilderContext() {
//     rawLogger.onRecord.listen(records.add);
//     rawLogger.onRecord.listen(print);
//   }
//
//   @override
//   BuildStep get buildStep => null;
//
//   @override
//   BuilderLogger get log => null;
// }

/// An in-memory implementation of [SummaryReader].
///
/// When [read] is called, it returns the mock summary.
class FakeSummaryReader implements SummaryReader {
  final Map<String, LibrarySummary> _summaries;

  /// Create a fake summary reader with previously created summaries.
  ///
  /// __Example use:__
  ///     return new FakeSummary({
  ///       'foo/foo.dart': new LibrarySummary(...)
  ///     });
  FakeSummaryReader(this._summaries);

  @override
  Future<LibrarySummary> read(String package, String path) {
    final fullPath = '$package/$path';
    final summary = _summaries[fullPath];
    if (summary == null) {
      throw FileSystemException('File not found', fullPath);
    }
    return Future<LibrarySummary>.value(summary);
  }
}
