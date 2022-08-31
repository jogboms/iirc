import 'package:firebase_core/firebase_core.dart' as firebase;
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  group('Firebase', () {
    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      setupFirebaseCoreMocks();
    });

    tearDown(() {
      TestFirebaseCoreHostApi.setup(null);
    });

    test('should initialize without errors', () async {
      final MockFirebaseAnalytics analytics = MockFirebaseAnalytics();

      await expectLater(
        Firebase.initialize(
          options: const firebase.FirebaseOptions(
            apiKey: '',
            appId: '',
            messagingSenderId: '',
            projectId: '',
            storageBucket: '',
          ),
          isAnalyticsEnabled: true,
          name: 'TEST',
          analytics: analytics,
          googleSignIn: MockGoogleSignIn(),
          auth: MockFirebaseAuth(),
          crashlytics: MockFirebaseCrashlytics(),
          firestore: MockFirebaseFirestore(),
        ),
        completes,
      );
      verify(() => analytics.setAnalyticsCollectionEnabled(true)).called(1);
    });
  });
}
