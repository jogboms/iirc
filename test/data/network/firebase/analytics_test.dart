import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  group('CloudAnalytics', () {
    late MockFirebaseAnalytics mockFirebaseAnalytics;
    late CloudAnalytics analytics;

    setUp(() {
      mockFirebaseAnalytics = MockFirebaseAnalytics();
      analytics = CloudAnalytics(mockFirebaseAnalytics);
    });

    test('should log event', () async {
      await analytics.log('name');
      await analytics.log('name', <String, String>{'1': 'one'});

      verify(() => mockFirebaseAnalytics.logEvent(name: 'name')).called(1);
      verify(() => mockFirebaseAnalytics.logEvent(name: 'name', parameters: <String, String>{'1': 'one'})).called(1);
    });

    test('should set current screen', () async {
      await analytics.setCurrentScreen('name');

      verify(() => mockFirebaseAnalytics.setCurrentScreen(screenName: 'name')).called(1);
    });

    test('should set user id', () async {
      await analytics.setUserId('id');

      verify(() => mockFirebaseAnalytics.setUserId(id: 'id')).called(1);
    });

    test('should remove user id', () async {
      await analytics.removeUserId();

      verify(() => mockFirebaseAnalytics.setUserId(id: null)).called(1);
    });
  });
}
