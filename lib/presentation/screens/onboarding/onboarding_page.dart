import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';

import '../../constants/app_routes.dart';
import '../../state.dart';
import '../../utils.dart';
import '../../widgets.dart';
import '../menu/menu_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.isColdStart});

  static PageRoute<void> route({required bool isColdStart}) {
    return MaterialPageRoute<void>(
      builder: (_) => OnboardingPage(isColdStart: isColdStart),
      settings: const RouteSettings(name: AppRoutes.onboarding),
    );
  }

  final bool isColdStart;

  @override
  State<OnboardingPage> createState() => OnboardingPageState();
}

@visibleForTesting
class OnboardingPageState extends State<OnboardingPage> {
  static const Key dataViewKey = Key('dataViewKey');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 124),
        child: UnconstrainedBox(
          child: _OnboardingDataView(
            key: dataViewKey,
            isColdStart: widget.isColdStart,
          ),
        ),
      ),
    );
  }
}

class _OnboardingDataView extends ConsumerStatefulWidget {
  const _OnboardingDataView({super.key, required this.isColdStart});

  final bool isColdStart;

  @override
  ConsumerState<_OnboardingDataView> createState() => OnboardingDataViewState();
}

@visibleForTesting
class OnboardingDataViewState extends ConsumerState<_OnboardingDataView> {
  static const Key signInButtonKey = Key('signInButtonKey');
  late final AuthStateNotifier auth = ref.read(authStateNotifierProvider.notifier);

  @override
  void initState() {
    super.initState();

    if (widget.isColdStart) {
      Future<void>.microtask(auth.signIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authStateNotifierProvider, _authStateListener);

    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      child: ref.watch(authStateNotifierProvider) == AuthState.loading
          ? const LoadingView()
          : ElevatedButton(
              key: signInButtonKey,
              onPressed: () {
                ref.read(analyticsProvider).log(AnalyticsEvent.buttonClick('login'));
                auth.signIn();
              },
              child: Text(context.l10n.continueWithGoogle),
            ),
    );
  }

  void _authStateListener(AuthState? _, AuthState state) {
    if (state is AuthErrorState) {
      final AppSnackBar snackBar = context.snackBar;
      final String message = state.toPrettyMessage(context.l10n, environment.isProduction);
      if (state.reason != AuthErrorStateReason.popupBlockedByBrowser) {
        snackBar.error(message);
      }
    } else if (state == AuthState.complete) {
      Navigator.of(context).pushReplacement(MenuPage.route());
    }
  }
}

extension on AuthErrorState {
  String toPrettyMessage(L10n l10n, bool isProduction) {
    switch (reason) {
      case AuthErrorStateReason.message:
        return isProduction ? l10n.genericErrorMessage : error;
      case AuthErrorStateReason.tooManyRequests:
        return l10n.tryAgainMessage;
      case AuthErrorStateReason.userDisabled:
        return l10n.bannedUserMessage;
      case AuthErrorStateReason.failed:
        return l10n.failedSignInMessage;
      case AuthErrorStateReason.networkUnavailable:
        return l10n.tryAgainMessage;
      case AuthErrorStateReason.popupBlockedByBrowser:
        return l10n.popupBlockedByBrowserMessage;
    }
  }
}
