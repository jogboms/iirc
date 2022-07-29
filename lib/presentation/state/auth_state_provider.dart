// ignore_for_file: always_specify_types

import 'package:clock/clock.dart';
import 'package:iirc/domain.dart';
import 'package:riverpod/riverpod.dart';

import 'registry_provider.dart';

final authStateProvider = StateNotifierProvider.autoDispose<AuthStateProvider, AuthState>(AuthStateProvider.new);

class AuthStateProvider extends StateNotifier<AuthState> {
  AuthStateProvider(AutoDisposeStateNotifierProviderRef ref)
      : _ref = ref,
        super(AuthState.idle);

  final AutoDisposeStateNotifierProviderRef _ref;

  void signIn() async {
    state = AuthState.loading;
    final di = _ref.read(registryProvider).get;

    try {
      final account = await di<SignInUseCase>().call();
      final user = await di<FetchUserUseCase>().call(account.id);
      if (user == null) {
        await di<CreateUserUseCase>().call(account);
      } else {
        await di<UpdateUserUseCase>().call(UpdateUserData(id: user.id, lastSeenAt: clock.now()));
      }

      if (mounted) {
        state = AuthState.complete;
      }
    } catch (e) {
      final String message = e.toString();
      if (message.isNotEmpty) {
        // TODO: log this
      }

      await di<SignOutUseCase>().call();
      if (mounted) {
        state = AuthState.idle;
      }
    }
  }

  void signOut() async {
    state = AuthState.loading;

    try {
      final registry = _ref.read(registryProvider);
      await registry.get<SignOutUseCase>().call();
      if (mounted) {
        state = AuthState.complete;
      }
    } catch (e) {
      final String message = e.toString();
      if (message.isNotEmpty) {
        // TODO: log this
      }

      if (mounted) {
        state = AuthState.idle;
      }
    }
  }
}

enum AuthState { idle, loading, complete }
