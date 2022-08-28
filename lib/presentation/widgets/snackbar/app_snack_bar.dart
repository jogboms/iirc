import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iirc/core.dart';

import '../../theme.dart';
import '../loading_spinner.dart';
import 'snack_bar_provider.dart';

class AppSnackBar {
  AppSnackBar.of(BuildContext context)
      : _context = context,
        state = SnackBarProvider.of(context);

  static const Key successKey = Key('snackBarSuccessKey');
  static const Key infoKey = Key('snackBarInfoKey');
  static const Key errorKey = Key('snackBarErrorKey');
  static const Key loadingKey = Key('snackBarLoadingKey');

  final BuildContext _context;
  final SnackBarProviderState? state;

  FutureOr<void> success(String value, {Duration? duration, Alignment? alignment}) => _show(
        value,
        key: successKey,
        leading: const Icon(Icons.check, color: Colors.white, size: 24),
        alignment: alignment,
        duration: duration,
        color: Colors.white,
        backgroundColor: AppColors.success,
      );

  FutureOr<void> info(String value, {Duration? duration, Alignment? alignment}) => _show(
        value,
        key: infoKey,
        leading: Icon(Icons.alarm, color: Theme.of(_context).primaryColor, size: 24),
        alignment: alignment,
        duration: duration,
        backgroundColor: Colors.white,
        color: Colors.black,
      );

  FutureOr<void> error(String value, {Duration? duration, Alignment? alignment}) => _show(
        value,
        key: errorKey,
        leading: const Icon(Icons.warning, color: Colors.white, size: 24),
        alignment: alignment,
        duration: duration,
        color: Colors.white,
        backgroundColor: AppColors.danger,
      );

  FutureOr<void> loading({
    String? value,
    Color? backgroundColor,
    Color? color,
    Alignment? alignment,
    bool dismissible = false,
  }) =>
      _show(
        value ?? L10n.of(_context).loadingMessage,
        key: loadingKey,
        color: color ?? Colors.black,
        alignment: alignment,
        dismissible: dismissible,
        backgroundColor: backgroundColor ?? Colors.white,
        duration: const Duration(days: 1),
        leading: LoadingSpinner.circle(size: 24, color: color),
      );

  FutureOr<void> _show(
    String? value, {
    required Key key,
    required Color backgroundColor,
    required Color color,
    Widget? leading,
    Duration? duration,
    bool dismissible = true,
    Alignment? alignment,
  }) =>
      state?.showSnackBar(
        _RowBar(
          key: Key(value ?? ''),
          backgroundColor: backgroundColor,
          children: <Widget>[
            if (leading != null) ...<Widget>[
              leading,
              const SizedBox(width: 16),
            ],
            Expanded(
              child: Text(
                value ?? '',
                style: TextStyle(fontSize: 14, color: color, fontWeight: AppFontWeight.semibold),
              ),
            ),
          ],
        ),
        key: key,
        duration: duration,
        alignment: alignment,
        dismissible: dismissible,
      );

  void hide() => state?.hideCurrentSnackBar();
}

class _RowBar extends StatelessWidget {
  const _RowBar({super.key, required this.children, this.backgroundColor});

  final List<Widget> children;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? theme.colorScheme.secondary,
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
        ],
        borderRadius: AppBorderRadius.c8,
      ),
      constraints: const BoxConstraints(minHeight: 54),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DefaultTextStyle(
        style: theme.textTheme.bodyMedium!,
        child: Row(children: children),
      ),
    );
  }
}

extension AppSnackBarBuildContextExtensions on BuildContext {
  AppSnackBar get snackBar => AppSnackBar.of(this);
}
