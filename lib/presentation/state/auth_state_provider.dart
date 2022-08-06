// ignore_for_file: always_specify_types

import 'package:clock/clock.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import 'registry_provider.dart';

final authStateProvider = StateNotifierProvider.autoDispose<AuthStateNotifier, AuthState>((ref) {
  final di = ref.read(registryProvider).get;

  return AuthStateNotifier(
    signInUseCase: di(),
    signOutUseCase: di(),
    fetchUserUseCase: di(),
    createUserUseCase: di(),
    updateUserUseCase: di(),
  );
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  @visibleForTesting
  AuthStateNotifier({
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.fetchUserUseCase,
    required this.createUserUseCase,
    required this.updateUserUseCase,
  }) : super(AuthState.idle);

  @visibleForTesting
  final SignInUseCase signInUseCase;
  @visibleForTesting
  final SignOutUseCase signOutUseCase;
  @visibleForTesting
  final FetchUserUseCase fetchUserUseCase;
  @visibleForTesting
  final CreateUserUseCase createUserUseCase;
  @visibleForTesting
  final UpdateUserUseCase updateUserUseCase;

  void signIn() async {
    state = AuthState.loading;

    try {
      final account = await signInUseCase();
      final user = await fetchUserUseCase(account.id);
      if (user == null) {
        await createUserUseCase(account);
      } else {
        await updateUserUseCase(UpdateUserData(id: user.id, lastSeenAt: clock.now()));
      }

      if (mounted) {
        state = AuthState.complete;
      }
    } catch (error, stackTrace) {
      final String message = error.toString();
      if (message.isNotEmpty) {
        AppLog.e(error, stackTrace);
      }

      await signOutUseCase();
      if (mounted) {
        state = AuthState.idle;
      }
    }
  }

  void signOut() async {
    state = AuthState.loading;

    try {
      await signOutUseCase();
      if (mounted) {
        state = AuthState.complete;
      }
    } catch (error, stackTrace) {
      final String message = error.toString();
      if (message.isNotEmpty) {
        AppLog.e(error, stackTrace);
      }

      if (mounted) {
        state = AuthState.idle;
      }
    }
  }
}

enum AuthState { idle, loading, complete }
