import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../registry.dart';
import 'registry_provider.dart';
import 'state_notifier_mixin.dart';

part 'auth_state_provider.g.dart';

@riverpod
class AuthStateNotifier extends _$AuthStateNotifier with StateNotifierMixin {
  @override
  AuthState build() => AuthState.idle;

  void signIn() async {
    final RegistryFactory di = ref.read(registryProvider).get;

    setState(AuthState.loading);

    try {
      final AccountEntity account = await di<SignInUseCase>()();
      final UserEntity? user = await di<FetchUserUseCase>()(account.id);
      if (user == null) {
        await di<CreateUserUseCase>()(account);
      } else {
        await di<UpdateUserUseCase>()(UpdateUserData(id: user.id, lastSeenAt: clock.now()));
      }

      setState(AuthState.complete);
    } on AuthException catch (error, stackTrace) {
      if (error is AuthExceptionCanceled) {
        setState(AuthState.idle);
      } else if (error is AuthExceptionNetworkUnavailable) {
        setState(AuthState.reason(AuthErrorStateReason.networkUnavailable));
      } else if (error is AuthExceptionPopupBlockedByBrowser) {
        setState(AuthState.reason(AuthErrorStateReason.popupBlockedByBrowser));
      } else if (error is AuthExceptionTooManyRequests) {
        setState(AuthState.reason(AuthErrorStateReason.tooManyRequests));
      } else if (error is AuthExceptionUserDisabled) {
        setState(AuthState.reason(AuthErrorStateReason.userDisabled));
      } else if (error is AuthExceptionFailed) {
        setState(AuthState.reason(AuthErrorStateReason.failed));
      } else {
        _handleError(error, stackTrace);
      }
    } catch (error, stackTrace) {
      await di<SignOutUseCase>()();
      _handleError(error, stackTrace);
    }
  }

  void signOut() async {
    setState(AuthState.loading);

    try {
      await ref.read(registryProvider).get<SignOutUseCase>()();
      setState(AuthState.complete);
    } catch (error, stackTrace) {
      _handleError(error, stackTrace);
    }
  }

  void _handleError(Object error, StackTrace stackTrace) {
    final String message = error.toString();
    AppLog.e(error, stackTrace);
    setState(AuthState.error(message));
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
  List<Object> get props => <Object>[type];
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
