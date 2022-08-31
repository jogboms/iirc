import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iirc/data.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  group('Auth', () {
    late MockFirebaseAuth mockFirebaseAuth;
    late MockGoogleSignIn mockGoogleSignIn;
    late Auth auth;

    setUp(() {
      mockFirebaseAuth = MockFirebaseAuth();
      mockGoogleSignIn = MockGoogleSignIn();
      auth = Auth(mockFirebaseAuth, mockGoogleSignIn);
    });

    test('should retrieve current user when available', () async {
      expect(auth.getUser, null);

      final FakeUser user = FakeUser(uid: '1', email: 'email', displayName: 'display name');
      when(() => mockFirebaseAuth.currentUser).thenReturn(user);

      expect(auth.getUser, FireUser(user));

      verify(() => mockFirebaseAuth.currentUser).called(2);
    });

    test('should react to auth state changes', () async {
      final StreamController<FakeUser?> controller = StreamController<FakeUser?>();
      when(() => mockFirebaseAuth.authStateChanges()).thenAnswer((_) => controller.stream);
      addTearDown(controller.close);

      controller
        ..add(FakeUser(uid: '1', email: 'a'))
        ..add(FakeUser(uid: '1', email: 'b'));

      expect(
        auth.onAuthStateChanged,
        emitsInOrder(<FireUser>[
          FireUser(FakeUser(uid: '1', email: 'a')),
          FireUser(FakeUser(uid: '1', email: 'b')),
        ]),
      );
    });

    group('Sign in w/ google', () {
      setUpAll(() {
        registerFallbackValue(FakeAuthCredential());
      });

      group('Get current user', () {
        setUp(() {
          when(() => mockFirebaseAuth.signInWithCredential(any())).thenAnswer((_) async => MockUserCredential());
        });

        test('should try current user first', () async {
          when(() => mockGoogleSignIn.currentUser).thenReturn(FakeGoogleSignInAccount());

          await auth.signInWithGoogle();

          verify(() => mockGoogleSignIn.currentUser).called(1);
          verifyNever(() => mockGoogleSignIn.signInSilently());
          verifyNever(() => mockGoogleSignIn.signIn());
        });

        test('should try sign in silently next', () async {
          when(() => mockGoogleSignIn.signInSilently()).thenAnswer((_) async => MockGoogleSignInAccount());

          await auth.signInWithGoogle();

          verify(() => mockGoogleSignIn.signInSilently()).called(1);
          verifyNever(() => mockGoogleSignIn.signIn());
        });

        test('should try sign in at last', () async {
          when(() => mockGoogleSignIn.signInSilently()).thenAnswer((_) async => null);
          when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => MockGoogleSignInAccount());

          await auth.signInWithGoogle();

          verify(() => mockGoogleSignIn.signInSilently()).called(1);
          verify(() => mockGoogleSignIn.signIn()).called(1);
        });
      });

      group('Exceptions', () {
        test('should throw canceled exception when failed to get user', () async {
          when(() => mockGoogleSignIn.signInSilently()).thenAnswer((_) async => null);
          when(() => mockGoogleSignIn.signIn()).thenAnswer((_) async => null);

          await expectLater(
            () => auth.signInWithGoogle(),
            throwsA(isA<AppFirebaseAuthException>().having(
              (AppFirebaseAuthException e) => e.type,
              'type',
              AppFirebaseAuthExceptionType.canceled,
            )),
          );
        });

        test('should remap thrown platform exceptions', () async {
          final Map<String, AppFirebaseAuthExceptionType> exceptions = <String, AppFirebaseAuthExceptionType>{
            GoogleSignIn.kSignInCanceledError: AppFirebaseAuthExceptionType.canceled,
            GoogleSignIn.kSignInFailedError: AppFirebaseAuthExceptionType.failed,
            GoogleSignIn.kNetworkError: AppFirebaseAuthExceptionType.networkUnavailable,
            'popup_blocked_by_browser': AppFirebaseAuthExceptionType.popupBlockedByBrowser,
          };

          for (final MapEntry<String, AppFirebaseAuthExceptionType> entry in exceptions.entries) {
            when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(PlatformException(code: entry.key));
            when(() => mockGoogleSignIn.currentUser).thenReturn(FakeGoogleSignInAccount());

            await expectLater(
              () => auth.signInWithGoogle(),
              throwsA(isA<AppFirebaseAuthException>().having(
                (AppFirebaseAuthException e) => e.type,
                'type',
                entry.value,
              )),
            );
          }
        });

        test('should throw generic exception for unknown platform exceptions', () async {
          when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(PlatformException(code: 'empty'));
          when(() => mockGoogleSignIn.currentUser).thenReturn(FakeGoogleSignInAccount());

          await expectLater(
            () => auth.signInWithGoogle(),
            throwsA(isA<Exception>().having(
              (Exception e) => e.toString(),
              'toString()',
              'Exception: PlatformException(empty, null, null, null)',
            )),
          );
        });

        test('should remap thrown firebase auth exceptions', () async {
          final Map<String, AppFirebaseAuthExceptionType> exceptions = <String, AppFirebaseAuthExceptionType>{
            'invalid-email': AppFirebaseAuthExceptionType.invalidEmail,
            'user-disabled': AppFirebaseAuthExceptionType.userDisabled,
            'user-not-found': AppFirebaseAuthExceptionType.userNotFound,
            'too-many-requests': AppFirebaseAuthExceptionType.tooManyRequests,
          };

          for (final MapEntry<String, AppFirebaseAuthExceptionType> entry in exceptions.entries) {
            when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(FirebaseAuthException(
              code: entry.key,
              email: 'email',
            ));
            when(() => mockGoogleSignIn.currentUser).thenReturn(FakeGoogleSignInAccount());

            await expectLater(
              () => auth.signInWithGoogle(),
              throwsA(isA<AppFirebaseAuthException>()
                  .having((AppFirebaseAuthException e) => e.type, 'type', entry.value)
                  .having((AppFirebaseAuthException e) => e.email, 'email', 'email')),
            );
          }
        });

        test('should throw generic exception for unknown firebase auth exceptions', () async {
          when(() => mockFirebaseAuth.signInWithCredential(any())).thenThrow(FirebaseAuthException(code: 'empty'));
          when(() => mockGoogleSignIn.currentUser).thenReturn(FakeGoogleSignInAccount());

          await expectLater(
            () => auth.signInWithGoogle(),
            throwsA(isA<Exception>().having(
              (Exception e) => e.toString(),
              'toString()',
              'Exception: [firebase_auth/empty] null',
            )),
          );
        });
      });
    });

    test('should sign out w/ google', () async {
      await auth.signOutWithGoogle();

      verify(() => mockFirebaseAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });
  });
}
