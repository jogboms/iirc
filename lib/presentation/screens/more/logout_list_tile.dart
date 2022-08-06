import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state.dart';
import '../../theme.dart';
import '../../utils.dart';
import '../onboarding/onboarding_page.dart';

class LogoutListTile extends ConsumerWidget {
  const LogoutListTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = context.theme;
    final Color color = theme.colorScheme.error;

    ref.listen<AuthState>(authStateProvider, (_, AuthState state) {
      if (state == AuthState.complete) {
        Navigator.of(context).pushAndRemoveUntil(
          OnboardingPage.route(isColdStart: false),
          (_) => false,
        );
      }
    });

    return ListTile(
      tileColor: theme.canvasColor,
      title: Text(
        context.l10n.logoutCaption,
        style: context.theme.textTheme.button?.copyWith(color: color),
      ),
      leading: Icon(
        Icons.power_settings_new_outlined,
        color: color,
      ),
      horizontalTitleGap: 0,
      onTap: () => ref.read(authStateProvider.notifier).signOut(),
    );
  }
}
