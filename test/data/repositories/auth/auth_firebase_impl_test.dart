import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  group('AuthFirebaseImpl', () {
    final Auth auth = MockAuth();
    final Firebase firebase = MockFirebase(auth: auth);
    final AuthFirebaseImpl repo = AuthFirebaseImpl(
      firebase: firebase,
      isDev: false,
    );

    tearDown(() {
      reset(auth);
    });

    group('Fetch', () {
      test('should return account', () {
        when(() => auth.getUser).thenAnswer(
          (_) => MockFireUser(uid: '1', email: 'email', displayName: 'display name'),
        );

        expect(
          repo.fetch(),
          completion(const AccountModel(
            id: '1',
            displayName: 'display name',
            email: 'email',
          )),
        );
      });

      test('should throw when no account', () {
        when(() => auth.getUser).thenAnswer((_) => null);

        expect(
          () => repo.fetch(),
          throwsA(isA<AuthExceptionUserNotFound>()),
        );
      });
    });

    group('Sign in', () {
      test('should return id', () {
        when(() => auth.signInWithGoogle()).thenAnswer((_) async => '1');

        expect(
          repo.signIn(),
          completion('1'),
        );
      });

      group('Exceptions', () {
        test('should handle when canceled', () {
          when(() => auth.signInWithGoogle()).thenThrow(
            const AppFirebaseAuthException(AppFirebaseAuthExceptionType.canceled, email: 'email'),
          );

          expect(
            () => repo.signIn(),
            throwsA(isA<AuthExceptionCanceled>()),
          );
        });

        test('should handle when failed', () {
          when(() => auth.signInWithGoogle()).thenThrow(
            const AppFirebaseAuthException(AppFirebaseAuthExceptionType.failed, email: 'email'),
          );

          expect(
            () => repo.signIn(),
            throwsA(isA<AuthExceptionFailed>()),
          );
        });

        test('should handle when network unavailable', () {
          when(() => auth.signInWithGoogle()).thenThrow(
            const AppFirebaseAuthException(AppFirebaseAuthExceptionType.networkUnavailable, email: 'email'),
          );

          expect(
            () => repo.signIn(),
            throwsA(isA<AuthExceptionNetworkUnavailable>()),
          );
        });

        test('should handle when invalid email', () {
          when(() => auth.signInWithGoogle()).thenThrow(
            const AppFirebaseAuthException(AppFirebaseAuthExceptionType.invalidEmail, email: 'email'),
          );

          expect(
            () => repo.signIn(),
            throwsA(
              isA<AuthExceptionInvalidEmail>().having((AuthExceptionInvalidEmail e) => e.email, 'email', 'email'),
            ),
          );
        });

        test('should handle when user not found', () {
          when(() => auth.signInWithGoogle()).thenThrow(
            const AppFirebaseAuthException(AppFirebaseAuthExceptionType.userNotFound, email: 'email'),
          );

          expect(
            () => repo.signIn(),
            throwsA(
              isA<AuthExceptionUserNotFound>().having((AuthExceptionUserNotFound e) => e.email, 'email', 'email'),
            ),
          );
        });

        test('should handle when too many requests', () {
          when(() => auth.signInWithGoogle()).thenThrow(
            const AppFirebaseAuthException(AppFirebaseAuthExceptionType.tooManyRequests, email: 'email'),
          );

          expect(
            () => repo.signIn(),
            throwsA(
              isA<AuthExceptionTooManyRequests>().having((AuthExceptionTooManyRequests e) => e.email, 'email', 'email'),
            ),
          );
        });

        test('should handle when user disabled', () {
          when(() => auth.signInWithGoogle()).thenThrow(
            const AppFirebaseAuthException(AppFirebaseAuthExceptionType.userDisabled, email: 'email'),
          );

          expect(
            () => repo.signIn(),
            throwsA(
              isA<AuthExceptionUserDisabled>().having((AuthExceptionUserDisabled e) => e.email, 'email', 'email'),
            ),
          );
        });

        test('should handle when unknown', () {
          when(() => auth.signInWithGoogle()).thenThrow(Exception());

          expect(
            () => repo.signIn(),
            throwsA(isA<AuthExceptionUnknown>()),
          );
        });
      });
    });

    group('On state change', () {
      test('should emit id', () {
        final StreamController<FireUser> controller = StreamController<FireUser>();
        when(() => auth.onAuthStateChanged).thenAnswer((_) => controller.stream);
        addTearDown(() => controller.close());

        controller.add(MockFireUser(uid: '1', email: 'email', displayName: 'display name'));
        controller.add(MockFireUser(uid: '2', email: 'email', displayName: 'display name'));

        expect(
          repo.onAuthStateChanged,
          emitsInOrder(<String>[
            '1',
            '2',
          ]),
        );
      });

      test('should bubble errors as AppException to current zone', () {
        when(() => auth.onAuthStateChanged).thenAnswer((_) => Stream<FireUser?>.error(Exception()));

        runZonedGuarded(
          () => expect(repo.onAuthStateChanged, emitsDone),
          (Object error, _) => expect(error, isA<AppException>()),
        );
      });
    });

    test('Sign out', () {
      when(() => auth.signOutWithGoogle()).thenAnswer((_) async {});

      expect(
        repo.signOut(),
        completes,
      );
    });
  });
}
