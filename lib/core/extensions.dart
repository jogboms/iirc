import 'package:flutter/material.dart';
import 'package:iirc/generated/l10n.dart';

extension L10nExtensions on BuildContext {
  L10n get l10n => L10n.of(this);
}

extension BuildContextThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
}

extension MenuPageThemeDataExtensions on ThemeData {
  Color get menuPageBackgroundColor => brightness == Brightness.light ? Colors.grey.shade200 : Colors.grey.shade400;
}

extension CalendarViewHeaderThemeDataExtensions on ThemeData {
  List<Color> get calendarViewHeaderGradient => <Color>[Colors.purpleAccent, Colors.blueAccent];
}

extension StringExtensions on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
