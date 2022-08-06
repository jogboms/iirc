import 'dart:async';

import 'package:clock/clock.dart';
import 'package:platform/platform.dart';

class ErrorReporter {
  ErrorReporter({
    this.client = const NoopReporterClient(),
    this.platform = const LocalPlatform(),
  });

  final ReporterClient client;

  final Platform platform;

  final Duration _lockDuration = const Duration(seconds: 10);

  DateTime? _lastReportTime;

  bool get _reportLocked => _lastReportTime != null && clock.now().difference(_lastReportTime!) < _lockDuration;

  Future<void> report(Object error, StackTrace stackTrace, [Object? extra]) async {
    if (_reportLocked) {
      return;
    }

    _lastReportTime = clock.now();

    try {
      await client.report(error: error, stackTrace: stackTrace, extra: extra);
    } catch (e) {
      log(error);
    }
  }

  void log(Object object) {
    client.log(object);
  }
}

abstract class ReporterClient {
  FutureOr<void> report({required StackTrace stackTrace, required Object error, Object? extra});

  void log(Object object);
}

class NoopReporterClient implements ReporterClient {
  const NoopReporterClient();

  @override
  FutureOr<void> report({required StackTrace stackTrace, required Object error, Object? extra}) {}

  @override
  void log(Object object) {}
}
