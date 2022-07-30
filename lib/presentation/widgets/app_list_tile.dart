import 'package:flutter/material.dart';

import '../theme/app_border_radius.dart';
import '../theme/extensions.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.child,
    required this.tagForegroundColor,
    required this.tagBackgroundColor,
    this.onPressed,
  });

  final Widget child;
  final Color tagForegroundColor;
  final Color tagBackgroundColor;
  final VoidCallback? onPressed;

  static const double height = 84;
  static const BorderRadius borderRadius = AppBorderRadius.c6;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: () => onPressed?.call(),
        borderRadius: borderRadius,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: <Widget>[
                SizedBox.fromSize(
                  size: const Size.fromWidth(4),
                  child: Material(
                    color: tagBackgroundColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppBorderRadius.c2,
                      side: BorderSide(color: tagForegroundColor, width: .5),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: child),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
