import 'dart:async' as async;

import 'package:flutter/widgets.dart';

import 'handle_uncaught_error.dart';

class ErrorBoundary {
  ErrorBoundary.runApp(
    Widget app, {
    required Widget Function(FlutterErrorDetails details) errorViewBuilder,
    required void Function(Object error, StackTrace stackTrace) onException,
    required bool isReleaseMode,
  }) {
    if (isReleaseMode) {
      ErrorWidget.builder = errorViewBuilder;
    }

    FlutterError.onError = (FlutterErrorDetails details) async {
      if (isReleaseMode) {
        handleUncaughtError(details.exception, details.stack ?? StackTrace.current);
      } else {
        FlutterError.presentError(details);
      }
    };

    async.runZonedGuarded(() => runApp(app), onException);
  }
}
