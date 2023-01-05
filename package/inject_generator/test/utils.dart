import 'dart:async';
import 'dart:convert';

import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:inject_generator/src/build/summary_builder.dart';
import 'package:inject_generator/src/summary.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

const rootPackage = 'inject_generator';

/// Matches a [LogRecord] on its [level] and [message].
Matcher logRecord(Level level, String message) {
  return _LogRecordMatcher(level, message);
}

/// Makes testing the [InjectSummaryBuilder] convenient.
class SummaryTestBed {
  /// AssetId of the content to test for the builder.
  final AssetId inputAssetId;

  /// Log records written by the builder.
  final List<LogRecord> logRecords = <LogRecord>[];

  final TestingAssetWriter _writer = TestingAssetWriter();

  /// Constructor.
  SummaryTestBed({required this.inputAssetId});

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
    final reader =
        await PackageAssetReader.currentIsolate(rootPackage: rootPackage);
    final content = await reader.readAsString(inputAssetId);

    const builder = InjectSummaryBuilder();
    await testBuilder(
      builder,
      {inputAssetId.toString(): content},
      isInput: (assetId) => assetId.startsWith(rootPackage),
      rootPackage: rootPackage,
      reader: reader,
      writer: _writer,
      onLog: logRecords.add,
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
