import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
  late final AuthStateNotifier auth = ref.read(authStateProvider.notifier);

  @override
  void initState() {
    super.initState();

    if (widget.isColdStart) {
      auth.signIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthState authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (_, AuthState state) {
      if (state == AuthState.complete) {
        Navigator.of(context).pushReplacement(MenuPage.route());
      }
    });

    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      child: authState == AuthState.loading
          ? const LoadingView()
          : ElevatedButton(
              key: signInButtonKey,
              onPressed: auth.signIn,
              child: Text(context.l10n.continueWithGoogle),
            ),
    );
  }
}
