import 'package:flutter/material.dart';
import 'package:iirc/generated/l10n.dart';

extension L10nExtensions on BuildContext {
  L10n get l10n => L10n.of(this);
}

extension StringExtensions on String {
  String capitalize() => this[0].toUpperCase() + substring(1);
}
