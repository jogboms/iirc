import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/state.dart';
import 'package:iirc/widgets.dart';

import '../menu_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key, required this.isColdStart});

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
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) {
          ref.listen<AsyncValue<String?>>(authIdProvider, (_, AsyncValue<String?> snapshot) {
            if (snapshot.value != null) {
              Navigator.of(context).pushReplacement(MenuPage.route());
            }
          });

          return _OnboardingDataView(
            key: dataViewKey,
            isColdStart: widget.isColdStart,
          );
        },
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
  late final AuthStateProvider auth = ref.read(authStateProvider.notifier);

  @override
  void initState() {
    super.initState();

    if (widget.isColdStart) {
      auth.signIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final AuthState authState = ref.watch(authStateProvider);

    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(bottom: 124),
      child: UnconstrainedBox(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: authState == AuthState.loading
              ? const LoadingView()
              : MaterialButton(
                  key: signInButtonKey,
                  elevation: 0,
                  color: theme.colorScheme.primary,
                  onPressed: auth.signIn,
                  child: Text(
                    context.l10n.continueWithGoogle,
                    style: theme.textTheme.bodyText1?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
