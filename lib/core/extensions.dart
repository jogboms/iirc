import 'package:flutter/widgets.dart';
import 'package:iirc/generated/l10n.dart';

extension L10nExtensions on BuildContext {
  S get l10n => S.of(this);
}
