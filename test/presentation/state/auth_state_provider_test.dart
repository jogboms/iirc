import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../mocks.dart';
import '../../utils.dart';

Future<void> main() async {
  group('AuthStateProvider', () {
    final List<AuthState> log = <AuthState>[];

    setUpAll(() {
      registerFallbackValue(FakeUpdateUserData());
      registerFallbackValue(FakeAccountEntity());
    });

    tearDown(mockUseCases.reset);

    AuthStateNotifier createProvider() {
      final ProviderContainer container = createProviderContainer();

      final AuthStateNotifier provider = container.read(authStateNotifierProvider.notifier);
      container.listen(authStateNotifierProvider, (_, AuthState next) => log.add(next));
      log.add(provider.currentState);

      addTearDown(container.dispose);
      addTearDown(log.clear);
      return provider;
    }

    test('should create new instance with idle state when read', () {
      final ProviderContainer container = createProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(authStateNotifierProvider), AuthState.idle);
    });

    group('AuthStateNotifier', () {
      group('Sign In', () {
        final AccountEntity dummyAccount = AuthMockImpl.generateAccount();
        final UserEntity dummyUser = UsersMockImpl.user;

        setUp(() {
          when(mockUseCases.signInUseCase.call).thenAnswer((_) async => dummyAccount);
        });

        test('should sign in known user and update user info', () async {
          when(() => mockUseCases.fetchUserUseCase.call(any())).thenAnswer((_) async => dummyUser);
          when(() => mockUseCases.updateUserUseCase.call(any())).thenAnswer((_) async => true);

          createProvider().signIn();

          await pumpEventQueue();

          expect(log, <AuthState>[
            AuthState.idle,
            AuthState.loading,
            AuthState.complete,
          ]);
          verify(mockUseCases.signInUseCase.call).called(1);
          verify(() => mockUseCases.fetchUserUseCase.call(dummyAccount.id)).called(1);
          verify(() => mockUseCases.updateUserUseCase.call(any())).called(1);
        });

        test('should update user info with current time after sign in', () async {
          when(() => mockUseCases.fetchUserUseCase.call(any())).thenAnswer((_) async => dummyUser);
          when(() => mockUseCases.updateUserUseCase.call(any())).thenAnswer((_) async => true);

          final DateTime now = DateTime(0);
          withClock(
            Clock(() => now),
            () => createProvider().signIn(),
          );

          await pumpEventQueue();

          final UpdateUserData captured = verify(
            () => mockUseCases.updateUserUseCase.call(captureAny()),
          ).captured.first as UpdateUserData;
          expect(captured, UpdateUserData(id: dummyUser.id, lastSeenAt: now));
        });

        test('should sign in unknown user and create user account', () async {
          when(() => mockUseCases.fetchUserUseCase.call(any())).thenAnswer((_) async => null);
          when(() => mockUseCases.createUserUseCase.call(any())).thenAnswer((_) async => '');

          createProvider().signIn();

          await pumpEventQueue();

          expect(log, <AuthState>[
            AuthState.idle,
            AuthState.loading,
            AuthState.complete,
          ]);
          verify(mockUseCases.signInUseCase.call).called(1);
          verify(() => mockUseCases.fetchUserUseCase.call(dummyAccount.id)).called(1);
          verify(() => mockUseCases.createUserUseCase.call(dummyAccount)).called(1);
        });

        group('should sign out', () {
          setUp(() {
            when(mockUseCases.signOutUseCase.call).thenAnswer((_) async {});
          });

          test('when sign in fails', () async {
            when(mockUseCases.signInUseCase.call).thenThrow(Exception());

            createProvider().signIn();

            await pumpEventQueue();

            expect(log, <AuthState>[
              AuthState.idle,
              AuthState.loading,
              AuthState.error('${Exception()}'),
            ]);
            verify(mockUseCases.signInUseCase.call).called(1);
            verify(mockUseCases.signOutUseCase.call).called(1);
          });

          test('when fetch user fails', () async {
            when(mockUseCases.signInUseCase.call).thenAnswer((_) async => dummyAccount);
            when(() => mockUseCases.fetchUserUseCase.call(any())).thenThrow(Exception());

            createProvider().signIn();

            await pumpEventQueue();

            expect(log, <AuthState>[
              AuthState.idle,
              AuthState.loading,
              AuthState.error('${Exception()}'),
            ]);
            verify(mockUseCases.signInUseCase.call).called(1);
            verify(() => mockUseCases.fetchUserUseCase.call(any())).called(1);
            verify(mockUseCases.signOutUseCase.call).called(1);
          });

          test('when create user fails', () async {
            when(mockUseCases.signInUseCase.call).thenAnswer((_) async => dummyAccount);
            when(() => mockUseCases.fetchUserUseCase.call(any())).thenAnswer((_) async => null);
            when(() => mockUseCases.createUserUseCase.call(any())).thenThrow(Exception());

            createProvider().signIn();

            await pumpEventQueue();

            expect(log, <AuthState>[
              AuthState.idle,
              AuthState.loading,
              AuthState.error('${Exception()}'),
            ]);
            verify(mockUseCases.signInUseCase.call).called(1);
            verify(() => mockUseCases.fetchUserUseCase.call(any())).called(1);
            verify(() => mockUseCases.createUserUseCase.call(any())).called(1);
            verify(mockUseCases.signOutUseCase.call).called(1);
          });

          test('when update user fails', () async {
            when(mockUseCases.signInUseCase.call).thenAnswer((_) async => dummyAccount);
            when(() => mockUseCases.fetchUserUseCase.call(any())).thenAnswer((_) async => dummyUser);
            when(() => mockUseCases.updateUserUseCase.call(any())).thenThrow(Exception());

            createProvider().signIn();

            await pumpEventQueue();

            expect(log, <AuthState>[
              AuthState.idle,
              AuthState.loading,
              AuthState.error('${Exception()}'),
            ]);
            verify(mockUseCases.signInUseCase.call).called(1);
            verify(() => mockUseCases.fetchUserUseCase.call(any())).called(1);
            verify(() => mockUseCases.updateUserUseCase.call(any())).called(1);
            verify(mockUseCases.signOutUseCase.call).called(1);
          });

          group('Exceptions', () {
            test('when canceled', () async {
              when(mockUseCases.signInUseCase.call).thenThrow(const AuthException.canceled());

              createProvider().signIn();

              await pumpEventQueue();

              expect(log, <AuthState>[
                AuthState.idle,
                AuthState.loading,
                AuthState.idle,
              ]);
            });

            test('when network unavailable', () async {
              when(mockUseCases.signInUseCase.call).thenThrow(const AuthException.networkUnavailable());

              createProvider().signIn();

              await pumpEventQueue();

              expect(log, <AuthState>[
                AuthState.idle,
                AuthState.loading,
                AuthState.reason(AuthErrorStateReason.networkUnavailable),
              ]);
            });

            test('when popup blocked by browser', () async {
              when(mockUseCases.signInUseCase.call).thenThrow(const AuthException.popupBlockedByBrowser());

              createProvider().signIn();

              await pumpEventQueue();

              expect(log, <AuthState>[
                AuthState.idle,
                AuthState.loading,
                AuthState.reason(AuthErrorStateReason.popupBlockedByBrowser),
              ]);
            });

            test('when too many requests', () async {
              when(mockUseCases.signInUseCase.call).thenThrow(const AuthException.tooManyRequests());

              createProvider().signIn();

              await pumpEventQueue();

              expect(log, <AuthState>[
                AuthState.idle,
                AuthState.loading,
                AuthState.reason(AuthErrorStateReason.tooManyRequests),
              ]);
            });

            test('when failed', () async {
              when(mockUseCases.signInUseCase.call).thenThrow(const AuthException.failed());

              createProvider().signIn();

              await pumpEventQueue();

              expect(log, <AuthState>[
                AuthState.idle,
                AuthState.loading,
                AuthState.reason(AuthErrorStateReason.failed),
              ]);
            });

            test('when user disabled', () async {
              when(mockUseCases.signInUseCase.call).thenThrow(const AuthException.userDisabled());

              createProvider().signIn();

              await pumpEventQueue();

              expect(log, <AuthState>[
                AuthState.idle,
                AuthState.loading,
                AuthState.reason(AuthErrorStateReason.userDisabled),
              ]);
            });

            test('when invalid email', () async {
              when(mockUseCases.signInUseCase.call).thenThrow(const AuthException.invalidEmail());

              createProvider().signIn();

              await pumpEventQueue();

              expect(log, <AuthState>[
                AuthState.idle,
                AuthState.loading,
                AuthState.error("Instance of 'AuthExceptionInvalidEmail'"),
              ]);
            });

            test('when user not found', () async {
              when(mockUseCases.signInUseCase.call).thenThrow(const AuthException.userNotFound());

              createProvider().signIn();

              await pumpEventQueue();

              expect(log, <AuthState>[
                AuthState.idle,
                AuthState.loading,
                AuthState.error("Instance of 'AuthExceptionUserNotFound'"),
              ]);
            });

            test('when unknown', () async {
              when(mockUseCases.signInUseCase.call).thenThrow(AuthException.unknown(Exception()));

              createProvider().signIn();

              await pumpEventQueue();

              expect(log, <AuthState>[
                AuthState.idle,
                AuthState.loading,
                AuthState.error("Instance of 'AuthExceptionUnknown'"),
              ]);
            });
          });
        });
      });

      group('Sign Out', () {
        test('should sign out', () async {
          when(mockUseCases.signOutUseCase.call).thenAnswer((_) async {});

          createProvider().signOut();

          await pumpEventQueue();

          expect(log, <AuthState>[
            AuthState.idle,
            AuthState.loading,
            AuthState.complete,
          ]);
          verify(mockUseCases.signOutUseCase.call).called(1);
        });

        test('should fail gracefully on error', () async {
          when(mockUseCases.signOutUseCase.call).thenThrow(Exception());

          createProvider().signOut();

          await pumpEventQueue();

          expect(log, <AuthState>[
            AuthState.idle,
            AuthState.loading,
            AuthState.error('${Exception()}'),
          ]);
          verify(mockUseCases.signOutUseCase.call).called(1);
        });
      });
    });
  });
}
