// ignore_for_file: always_specify_types

import 'package:iirc/domain.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final authStateProvider = StateNotifierProvider.autoDispose<AuthStateProvider, AuthState>(AuthStateProvider.new);

class AuthStateProvider extends StateNotifier<AuthState> {
  AuthStateProvider(AutoDisposeStateNotifierProviderRef ref)
      : _ref = ref,
        super(AuthState.idle);

  final AutoDisposeStateNotifierProviderRef _ref;

  void signIn() async {
    state = AuthState.loading;
    final registry = _ref.read(registryProvider);

    try {
      await registry.get<SignInUseCase>().call();
    } catch (e) {
      final String message = e.toString();
      if (message.isNotEmpty) {
        // TODO: log this
      }

      await registry.get<SignOutUseCase>().call();
      if (mounted) {
        state = AuthState.idle;
      }
    }
  }

  void signOut() async {
    state = AuthState.loading;

    try {
      final registry = _ref.read(registryProvider);
      return registry.get<SignOutUseCase>().call();
    } finally {
      if (mounted) {
        state = AuthState.idle;
      }
    }
  }
}

enum AuthState { idle, loading }
