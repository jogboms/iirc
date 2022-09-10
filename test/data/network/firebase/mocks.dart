// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iirc/data.dart';
import 'package:mocktail/mocktail.dart';

class FakeAuthCredential extends Mock implements AuthCredential {}

class MockUserCredential extends Mock implements UserCredential {
  MockUserCredential() {
    when(() => user).thenReturn(FakeUser(uid: '1'));
  }
}

class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {
  MockGoogleSignInAuthentication() {
    when(() => accessToken).thenReturn('accessToken');
  }
}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {
  MockGoogleSignInAccount() {
    when(() => authentication).thenAnswer((_) async => MockGoogleSignInAuthentication());
  }
}

class FakeGoogleSignInAccount extends Fake implements GoogleSignInAccount {
  @override
  Future<GoogleSignInAuthentication> get authentication =>
      Future<GoogleSignInAuthentication>.value(MockGoogleSignInAuthentication());
}

class MockUser extends Mock implements User {
  MockUser() {
    when(() => uid).thenReturn('1');
    when(() => email).thenReturn('email');
    when(() => displayName).thenReturn('display name');
  }
}

class FakeUser extends Fake implements User {
  FakeUser({required this.uid, this.email, this.displayName});

  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;
}

class MockGoogleSignIn extends Mock implements GoogleSignIn {
  MockGoogleSignIn() {
    when(() => signOut()).thenAnswer((_) async => null);
  }
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  MockFirebaseAuth() {
    when(() => signOut()).thenAnswer((_) async => true);
  }
}

class MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {
  MockFirebaseCrashlytics() {
    when(
      () => recordError(
        any<dynamic>(),
        any(),
        information: any(named: 'information'),
        reason: any<dynamic>(named: 'reason'),
        printDetails: any(named: 'printDetails'),
        fatal: any(named: 'fatal'),
      ),
    ).thenAnswer((_) async => true);
    when(() => recordFlutterFatalError(any())).thenAnswer((_) async => true);
  }
}

class MockFirebaseAnalytics extends Mock implements FirebaseAnalytics {
  MockFirebaseAnalytics() {
    when(() => logEvent(name: any(named: 'name'), parameters: any(named: 'parameters'))).thenAnswer((_) async => true);
    when(() => setCurrentScreen(screenName: any(named: 'screenName'))).thenAnswer((_) async => true);
    when(() => setUserId(id: any(named: 'id'))).thenAnswer((_) async => true);
    when(() => setUserId(id: any(named: 'id'))).thenAnswer((_) async => true);
    when(() => setAnalyticsCollectionEnabled(any())).thenAnswer((_) async {});
  }
}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  MockFirebaseFirestore() {
    when(() => collection(any())).thenReturn(MockMapCollectionReference());
    when(() => doc(any())).thenReturn(MockMapDocumentReference());
  }
}

class MockMapCollectionReference extends Mock implements MapCollectionReference {}

class MockMapDocumentReference extends Mock implements MapDocumentReference {}
