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
      registerFallbackValue(FakeAccountModel());
    });

    tearDown(() => mockUseCases.reset());

    AuthStateNotifier createProvider() {
      final AuthStateNotifier provider = AuthStateNotifier(
        signInUseCase: mockUseCases.signInUseCase,
        createUserUseCase: mockUseCases.createUserUseCase,
        fetchUserUseCase: mockUseCases.fetchUserUseCase,
        signOutUseCase: mockUseCases.signOutUseCase,
        updateUserUseCase: mockUseCases.updateUserUseCase,
      )..addListener(log.add);
      addTearDown(provider.dispose);
      addTearDown(log.clear);
      return provider;
    }

    test('should create new instance with idle state when read', () {
      final ProviderContainer container = createProviderContainer(
        overrides: <Override>[
          registryProvider.overrideWithValue(
            createRegistry(),
          ),
        ],
      );
      addTearDown(() => container.dispose());

      expect(container.read(authStateProvider), AuthState.idle);
    });

    group('AuthStateNotifier', () {
      group('Sign In', () {
        final AccountModel dummyAccount = AuthMockImpl.generateAccount();
        final UserModel dummyUser = UsersMockImpl.user;

        setUp(() {
          when(() => mockUseCases.signInUseCase.call()).thenAnswer((_) async => dummyAccount);
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
          verify(() => mockUseCases.signInUseCase.call()).called(1);
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
          verify(() => mockUseCases.signInUseCase.call()).called(1);
          verify(() => mockUseCases.fetchUserUseCase.call(dummyAccount.id)).called(1);
          verify(() => mockUseCases.createUserUseCase.call(dummyAccount)).called(1);
        });

        group('should sign out', () {
          setUp(() {
            when(() => mockUseCases.signOutUseCase.call()).thenAnswer((_) async {});
          });

          test('when sign in fails', () async {
            when(() => mockUseCases.signInUseCase.call()).thenThrow(Exception());

            createProvider().signIn();

            await pumpEventQueue();

            expect(log, <AuthState>[
              AuthState.idle,
              AuthState.loading,
              AuthState.idle,
            ]);
            verify(() => mockUseCases.signInUseCase.call()).called(1);
            verify(() => mockUseCases.signOutUseCase.call()).called(1);
          });

          test('when fetch user fails', () async {
            when(() => mockUseCases.signInUseCase.call()).thenAnswer((_) async => dummyAccount);
            when(() => mockUseCases.fetchUserUseCase.call(any())).thenThrow(Exception());

            createProvider().signIn();

            await pumpEventQueue();

            expect(log, <AuthState>[
              AuthState.idle,
              AuthState.loading,
              AuthState.idle,
            ]);
            verify(() => mockUseCases.signInUseCase.call()).called(1);
            verify(() => mockUseCases.fetchUserUseCase.call(any())).called(1);
            verify(() => mockUseCases.signOutUseCase.call()).called(1);
          });

          test('when create user fails', () async {
            when(() => mockUseCases.signInUseCase.call()).thenAnswer((_) async => dummyAccount);
            when(() => mockUseCases.fetchUserUseCase.call(any())).thenAnswer((_) async => null);
            when(() => mockUseCases.createUserUseCase.call(any())).thenThrow(Exception());

            createProvider().signIn();

            await pumpEventQueue();

            expect(log, <AuthState>[
              AuthState.idle,
              AuthState.loading,
              AuthState.idle,
            ]);
            verify(() => mockUseCases.signInUseCase.call()).called(1);
            verify(() => mockUseCases.fetchUserUseCase.call(any())).called(1);
            verify(() => mockUseCases.createUserUseCase.call(any())).called(1);
            verify(() => mockUseCases.signOutUseCase.call()).called(1);
          });

          test('when update user fails', () async {
            when(() => mockUseCases.signInUseCase.call()).thenAnswer((_) async => dummyAccount);
            when(() => mockUseCases.fetchUserUseCase.call(any())).thenAnswer((_) async => dummyUser);
            when(() => mockUseCases.updateUserUseCase.call(any())).thenThrow(Exception());

            createProvider().signIn();

            await pumpEventQueue();

            expect(log, <AuthState>[
              AuthState.idle,
              AuthState.loading,
              AuthState.idle,
            ]);
            verify(() => mockUseCases.signInUseCase.call()).called(1);
            verify(() => mockUseCases.fetchUserUseCase.call(any())).called(1);
            verify(() => mockUseCases.updateUserUseCase.call(any())).called(1);
            verify(() => mockUseCases.signOutUseCase.call()).called(1);
          });
        });
      });

      group('Sign Out', () {
        test('should sign out', () async {
          when(() => mockUseCases.signOutUseCase.call()).thenAnswer((_) async {});

          createProvider().signOut();

          await pumpEventQueue();

          expect(log, <AuthState>[
            AuthState.idle,
            AuthState.loading,
            AuthState.complete,
          ]);
          verify(() => mockUseCases.signOutUseCase.call()).called(1);
        });

        test('should fail gracefully on error', () async {
          when(() => mockUseCases.signOutUseCase.call()).thenThrow(Exception());

          createProvider().signOut();

          await pumpEventQueue();

          expect(log, <AuthState>[
            AuthState.idle,
            AuthState.loading,
            AuthState.idle,
          ]);
          verify(() => mockUseCases.signOutUseCase.call()).called(1);
        });
      });
    });
  });
}
