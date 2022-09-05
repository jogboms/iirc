import 'dart:async' as async;

import 'package:flutter/widgets.dart';

class ErrorBoundary {
  ErrorBoundary.runApp(
    Widget app, {
    required Widget Function(FlutterErrorDetails details) errorViewBuilder,
    required void Function(Object error, StackTrace stackTrace) onException,
    required void Function(FlutterErrorDetails details) onCrash,
    required bool isReleaseMode,
  }) {
    if (isReleaseMode) {
      ErrorWidget.builder = errorViewBuilder;
    }

    FlutterError.onError = (FlutterErrorDetails details) async {
      if (isReleaseMode) {
        onCrash(details);
      } else {
        FlutterError.presentError(details);
      }
    };

    async.runZonedGuarded(() => runApp(app), onException);
  }
}
