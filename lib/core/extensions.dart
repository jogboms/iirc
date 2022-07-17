import 'package:flutter/material.dart';
import 'package:iirc/generated/l10n.dart';

extension L10nExtensions on BuildContext {
  S get l10n => S.of(this);
}

extension BuildContextThemeExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);
}

extension StringExtensions on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
