import 'package:flutter/material.dart';

import '../constants/app_images.dart';
import '../theme/app_theme.dart';
import '../theme/extensions.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({super.key, this.heroTag, this.size = const Size.square(56), this.backgroundColor});

  final Size size;
  final String? heroTag;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Hero(
        tag: heroTag ?? 'TheAmazingAppIcon',
        child: Container(
          constraints: BoxConstraints.tight(size),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: backgroundColor ?? _deriveBackgroundColor(context.theme),
            borderRadius: BorderRadius.circular(size.shortestSide / 4),
          ),
          child: const Image(image: AppImages.iconTransparent, fit: BoxFit.contain),
        ),
      );

  Color _deriveBackgroundColor(ThemeData theme) =>
      theme.brightness != Brightness.light ? theme.colorScheme.secondary : theme.appTheme.splashBackgroundColor;
}
