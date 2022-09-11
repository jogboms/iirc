import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks.dart';

void main() {
  group('mapErrorToAppException', () {
    setUpAll(() {
      registerFallbackValue(FakeStackTrace());
    });

    test('should rewrite firebase exception with message to AppException', () async {
      final MockErrorHandler handler = MockErrorHandler();
      final Exception exception = AppFirebaseException(plugin: '', message: 'message');
      final Stream<int> stream = Stream<int>.error(exception);

      await runZonedGuarded(
        () async => _waitForStream(stream.mapErrorToAppException(true)),
        handler,
      );

      verify(() => handler.call(const AppException('message'), any())).called(1);
    });

    test('should rewrite firebase exception with code to AppException', () async {
      final MockErrorHandler handler = MockErrorHandler();
      final Exception exception = AppFirebaseException(plugin: '', code: 'code');
      final Stream<int> stream = Stream<int>.error(exception);

      await runZonedGuarded(
        () async => _waitForStream(stream.mapErrorToAppException(true)),
        handler,
      );

      verify(() => handler.call(const AppException('code'), any())).called(1);
    });

    test('should rewrite firebase exception with permission-denied code to AppException', () async {
      final MockErrorHandler handler = MockErrorHandler();
      final Exception exception = AppFirebaseException(plugin: '', code: 'permission-denied');
      final Stream<int> stream = Stream<int>.error(exception);

      await runZonedGuarded(
        () async => _waitForStream(stream.mapErrorToAppException(false)),
        handler,
      );

      verifyNever(() => handler.call(const AppException('permission-denied'), any()));
    });

    test('should swallow firebase exception with permission-denied code and in production', () async {
      final MockErrorHandler handler = MockErrorHandler();
      final Exception exception = AppFirebaseException(plugin: '', code: 'permission-denied');
      final Stream<int> stream = Stream<int>.error(exception);

      await runZonedGuarded(
        () async => _waitForStream(stream.mapErrorToAppException(true)),
        handler,
      );

      verify(() => handler.call(const AppException('permission-denied'), any())).called(1);
    });

    test('should rewrite exceptions to AppException', () async {
      final MockErrorHandler handler = MockErrorHandler();
      final Exception exception = Exception();
      final Stream<int> stream = Stream<int>.error(exception);

      await runZonedGuarded(
        () async => _waitForStream(stream.mapErrorToAppException(true)),
        handler,
      );

      verify(() => handler.call(AppException('$exception'), any())).called(1);
    });

    test('should rewrite errors to AppException', () async {
      final MockErrorHandler handler = MockErrorHandler();
      final Error error = UnimplementedError();
      final Stream<int> stream = Stream<int>.error(error);

      await runZonedGuarded(
        () async => _waitForStream(stream.mapErrorToAppException(true)),
        handler,
      );

      verify(() => handler.call(AppException('$error'), any())).called(1);
    });
  });
}

class MockErrorHandler extends Mock {
  void call(Object error, StackTrace stack);
}

Future<void> _waitForStream<T>(Stream<T> stream) async {
  await for (final T _ in stream) {}
}
