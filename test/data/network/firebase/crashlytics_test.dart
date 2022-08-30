import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:mocktail/mocktail.dart';

import 'utils.dart';

void main() {
  group('Crashlytics', () {
    late MockFirebaseCrashlytics mockFirebaseCrashlytics;
    late Crashlytics crashlytics;

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
  });
}
