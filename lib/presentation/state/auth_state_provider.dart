// ignore_for_file: always_specify_types

import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
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
    _setState(AuthState.loading);

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

      _setState(AuthState.complete);
    } on AuthException catch (error, stackTrace) {
      if (error is AuthExceptionCanceled) {
        _setState(AuthState.idle);
      } else if (error is AuthExceptionNetworkUnavailable) {
        _setState(AuthState.reason(AuthErrorStateReason.networkUnavailable));
      } else if (error is AuthExceptionPopupBlockedByBrowser) {
        _setState(AuthState.reason(AuthErrorStateReason.popupBlockedByBrowser));
      } else if (error is AuthExceptionTooManyRequests) {
        await analytics.log(AnalyticsEvent.tooManyRequests(error.email));
        _setState(AuthState.reason(AuthErrorStateReason.tooManyRequests));
      } else if (error is AuthExceptionUserDisabled) {
        await analytics.log(AnalyticsEvent.userDisabled(error.email));
        _setState(AuthState.reason(AuthErrorStateReason.userDisabled));
      } else if (error is AuthExceptionFailed) {
        AppLog.e(error, stackTrace);
        _setState(AuthState.reason(AuthErrorStateReason.failed));
      } else {
        _handleError(error, stackTrace);
      }
    } catch (error, stackTrace) {
      await signOutUseCase();
      _handleError(error, stackTrace);
    }
  }

  void signOut() async {
    _setState(AuthState.loading);

    try {
      await signOutUseCase();
      await analytics.log(AnalyticsEvent.logout);
      await analytics.removeUserId();

      _setState(AuthState.complete);
    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  void _setState(AuthState newState) {
    if (mounted) {
      state = newState;
    }
  }

  void _handleError(Object error, StackTrace stackTrace) {
    final String message = error.toString();
    AppLog.e(error, stackTrace);
    _setState(AuthState.error(message));
  }
}

@visibleForTesting
enum AuthStateType { idle, loading, error, complete }

class AuthState with EquatableMixin {
  const AuthState(this.type);

  factory AuthState.error(String error, [AuthErrorStateReason reason]) = AuthErrorState;

  factory AuthState.reason(AuthErrorStateReason reason) => AuthState.error('', reason);

  static const AuthState idle = AuthState(AuthStateType.idle);
  static const AuthState loading = AuthState(AuthStateType.loading);
  static const AuthState complete = AuthState(AuthStateType.complete);

  @visibleForTesting
  final AuthStateType type;

  @override
  List<Object> get props => [type];
}

enum AuthErrorStateReason {
  message,
  failed,
  networkUnavailable,
  popupBlockedByBrowser,
  tooManyRequests,
  userDisabled,
}

class AuthErrorState extends AuthState {
  const AuthErrorState(this.error, [this.reason = AuthErrorStateReason.message]) : super(AuthStateType.error);

  final String error;
  final AuthErrorStateReason reason;

  @override
  List<Object> get props => <Object>[...super.props, error, reason];
}
