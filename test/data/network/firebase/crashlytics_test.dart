import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';
import 'mocks.dart';

void main() {
  group('Crashlytics', () {
    late MockFirebaseCrashlytics mockFirebaseCrashlytics;
    late Crashlytics crashlytics;

    setUpAll(() {
      registerFallbackValue(FakeFlutterErrorDetails());
    });

    setUp(() {
      mockFirebaseCrashlytics = MockFirebaseCrashlytics();
      crashlytics = Crashlytics(mockFirebaseCrashlytics);
    });

    test('should report error', () async {
      final Exception error = Exception();
      await crashlytics.report(error, StackTrace.empty);

      verify(
        () => mockFirebaseCrashlytics.recordError(
          error,
          StackTrace.empty,
          information: <DiagnosticsNode>[],
          reason: null,
          printDetails: null,
          fatal: false,
        ),
      ).called(1);
    });

    test('should report crash', () async {
      final FlutterErrorDetails errorDetails = FlutterErrorDetails(exception: Exception());
      await crashlytics.reportCrash(errorDetails);

      verify(() => mockFirebaseCrashlytics.recordFlutterFatalError(errorDetails)).called(1);
    });
  });
}
