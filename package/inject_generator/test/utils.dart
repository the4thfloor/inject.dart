import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:inject_generator/src/build/summary_builder.dart';
import 'package:inject_generator/src/summary.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

/// Tests that [buggyCode] produces the [expectedWarning].
///
/// Example:
///
///     testShouldWarn(
///       'when code has no inject annotations',
///       '''
///         class Foo {}
///       ''',
///       'no @module, @injector or @provide annotated classes found.',
///     )
void testShouldWarn(
  String description, {
  required String buggyCode,
  required String expectedWarning,
}) {
  test('should warn $description', () async {
    final tb = SummaryTestBed(
      pkg: 'a',
      inputs: {
        'a|lib/buggy_code.dart': buggyCode,
      },
    );
    await tb.run();

    tb.expectLogRecord(Level.WARNING, expectedWarning);
  });
}

/// Matches a [LogRecord] on its [level] and [message].
Matcher logRecord(Level level, String message) {
  return _LogRecordMatcher(level, message);
}

/// Makes testing the [InjectSummaryBuilder] convenient.
class SummaryTestBed {
  /// Test package being processed by the summary builder.
  final String pkg;

  /// Input files for the builder.
  final Map<String, String> inputs;

  /// Log records written by the builder.
  final List<LogRecord> logRecords = <LogRecord>[];

  final TestingAssetWriter _writer = TestingAssetWriter();

  /// Constructor.
  SummaryTestBed({required this.pkg, required this.inputs});

  /// Generated library summaries keyed by their paths.
  Map<String, LibrarySummary> get summaries => _writer.summaries;

  /// Verifies that [logRecords] contains a message with the desired [level] and
  /// [message].
  void expectLogRecord(Level level, String message) {
    expect(logRecords, contains(logRecord(level, message)));
  }

  /// Verifies that [logRecords] contains [expectedCount] number of messages
  /// that match [message].
  void expectLogRecordCount(Level level, String message, int expectedCount) {
    final matcher = logRecord(level, message);
    final count = logRecords
        .map((record) => matcher.matches(record, {}))
        .where((matches) => matches)
        .length;
    expect(
      count,
      expectedCount,
      reason: 'Expected the log to $expectedCount messages with "$message" '
          'but found $count. The log contains:\n${logRecords.join('\n')}',
    );
  }

  /// Prints recorded log messages to standard output.
  ///
  /// This method is meant to be used for debugging tests.
  void printLog() {
    for (final record in logRecords) {
      print(record);
    }
  }

  /// Runs the [InjectSummaryBuilder].
  Future<void> run() async {
    final reader = await PackageAssetReader.currentIsolate();
    final metadata = await reader.readAsString(
      AssetId('inject', 'lib/inject.dart'),
    );
    inputs.addAll({
      'inject|lib/inject.dart': metadata,
    });
    const builder = InjectSummaryBuilder();
    await testBuilder(
      builder,
      inputs,
      rootPackage: pkg,
      isInput: (assetId) => assetId.startsWith(pkg),
      onLog: logRecords.add,
      writer: _writer,
    );
  }
}

class _LogRecordMatcher extends Matcher {
  final Level level;
  final String message;

  _LogRecordMatcher(this.level, this.message);

  @override
  Description describe(Description description) {
    description.add('log record of level $level with message "$message".');
    return description;
  }

  @override
  bool matches(item, Map matchState) {
    return item is LogRecord &&
        item.level == level &&
        item.message.contains(message);
  }
}

class TestingAssetWriter extends InMemoryAssetWriter {
  final Map<String, LibrarySummary> summaries = <String, LibrarySummary>{};
  final Map<String, String> genfiles = <String, String>{};

  TestingAssetWriter();

  @override
  Future writeAsString(
    AssetId id,
    String contents, {
    Encoding encoding = utf8,
  }) async {
    await super.writeAsString(id, contents, encoding: encoding);
    if (id.path.endsWith('.inject.summary')) {
      summaries[id.toString()] =
          LibrarySummary.parseJson(json.decode(contents));
    }
    if (id.path.endsWith('.inject.dart')) {
      genfiles[id.toString()] = contents;
    }
  }
}
