import 'package:flutter/material.dart';

import 'app_theme.dart';

extension BuildContextThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
}

extension MenuPageThemeDataExtensions on ThemeData {
  Color get menuPageBackgroundColor =>
      brightness == Brightness.light ? appTheme.hintColor.shade200 : appTheme.hintColor.shade400;
}
