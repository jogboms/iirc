import 'package:flutter/material.dart';
import 'package:iirc/core.dart';

class AppListTile extends StatelessWidget {
  const AppListTile({
    super.key,
    required this.child,
    required this.color,
    this.onPressed,
  });

  final Widget child;
  final Color color;
  final VoidCallback? onPressed;

  static const double height = 84;
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(6));

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
                    color: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                      side: BorderSide(color: Colors.grey.shade600),
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
