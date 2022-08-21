// ignore_for_file: always_specify_types

import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import 'registry_provider.dart';

final authStateProvider = StateNotifierProvider.autoDispose<AuthStateNotifier, AuthState>((ref) {
  final di = ref.read(registryProvider).get;

  return AuthStateNotifier(
    analytics: di(),
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
    required this.analytics,
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.fetchUserUseCase,
    required this.createUserUseCase,
    required this.updateUserUseCase,
  }) : super(AuthState.idle);

  @visibleForTesting
  final Analytics analytics;
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

      await analytics.setUserId(account.id);
      await analytics.log(AnalyticsEvent.login(account.email, account.id));

      if (mounted) {
        state = AuthState.complete;
      }
    } on AuthException catch (error, stackTrace) {
      if (error is AuthExceptionCanceled) {
        state = AuthState.idle;
      } else if (error is AuthExceptionTooManyRequests) {
        await analytics.log(AnalyticsEvent.tooManyRequests(error.email));
        state = AuthState.error('', AuthErrorStateReason.tooManyRequests);
      } else if (error is AuthExceptionUserDisabled) {
        await analytics.log(AnalyticsEvent.userDisabled(error.email));
        state = AuthState.error('', AuthErrorStateReason.userDisabled);
      } else {
        _handleError(error, stackTrace);
      }
    } catch (error, stackTrace) {
      await signOutUseCase();
      _handleError(error, stackTrace);
    }
  }

  void signOut() async {
    state = AuthState.loading;

    try {
      await signOutUseCase();
      await analytics.log(AnalyticsEvent.logout);
      await analytics.removeUserId();

      if (mounted) {
        state = AuthState.complete;
      }
    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  void _handleError(Object error, StackTrace stackTrace) {
    if (mounted) {
      final String message = error.toString();
      if (message.isNotEmpty) {
        AppLog.e(error, stackTrace);
        state = AuthState.error(message);
      } else {
        state = AuthState.idle;
      }
    }
  }
}

enum _AuthStateType { idle, loading, error, complete }

class AuthState with EquatableMixin {
  const AuthState(this._type);

  factory AuthState.error(String error, [AuthErrorStateReason reason]) = AuthErrorState;

  static const AuthState idle = AuthState(_AuthStateType.idle);
  static const AuthState loading = AuthState(_AuthStateType.loading);
  static const AuthState complete = AuthState(_AuthStateType.complete);

  final _AuthStateType _type;

  @override
  List<Object> get props => [_type];
}

enum AuthErrorStateReason { message, tooManyRequests, userDisabled }

class AuthErrorState extends AuthState {
  const AuthErrorState(this.error, [this.reason = AuthErrorStateReason.message]) : super(_AuthStateType.error);

  final String error;
  final AuthErrorStateReason reason;

  @override
  List<Object> get props => <Object>[...super.props, error];
}
