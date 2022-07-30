import 'package:flutter/material.dart';

import '../theme/extensions.dart';
import 'extensions.dart';

Future<bool> showErrorChoiceBanner(
  BuildContext context, {
  required String message,
}) async {
  final ThemeData theme = context.theme;
  final ScaffoldMessengerState scaffoldMessengerState = ScaffoldMessenger.of(context)
    ..removeCurrentMaterialBanner(reason: MaterialBannerClosedReason.dismiss);

  final Future<MaterialBannerClosedReason> result = scaffoldMessengerState
      .showMaterialBanner(
        MaterialBanner(
          backgroundColor: theme.colorScheme.errorContainer,
          content: Text(context.l10n.areYouSureAboutThisMessage),
          contentTextStyle: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onErrorContainer,
          ),
          actions: <Widget>[
            IconButton(
              onPressed: () => scaffoldMessengerState.removeCurrentMaterialBanner(),
              icon: const Icon(Icons.check_outlined),
              color: theme.colorScheme.onErrorContainer,
            ),
            IconButton(
              onPressed: () => scaffoldMessengerState.hideCurrentMaterialBanner(),
              icon: const Icon(Icons.close_outlined),
              color: theme.colorScheme.onErrorContainer,
            ),
          ],
        ),
      )
      .closed;

  return await result == MaterialBannerClosedReason.remove;
}
