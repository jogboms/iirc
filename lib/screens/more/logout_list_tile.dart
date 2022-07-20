import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/screens.dart';
import 'package:iirc/state.dart';

class LogoutListTile extends ConsumerWidget {
  const LogoutListTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = context.theme;

    ref.listen<AsyncValue<String?>>(authIdProvider, (_, AsyncValue<String?> snapshot) {
      if (snapshot.value == null) {
        Navigator.of(context).pushAndRemoveUntil(
          OnboardingPage.route(isColdStart: false),
          (_) => false,
        );
      }
    });

    return ListTile(
      tileColor: theme.canvasColor,
      title: Text(context.l10n.logoutCaption),
      textColor: theme.colorScheme.error,
      leading: Icon(
        Icons.power_settings_new_outlined,
        color: theme.colorScheme.error,
      ),
      horizontalTitleGap: 0,
      onTap: () => ref.read(authStateProvider.notifier).signOut(),
    );
  }
}
