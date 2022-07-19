import 'package:flutter/material.dart';
import 'package:iirc/core.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  const CustomAppBar({
    super.key,
    required this.title,
    this.actions = const <Widget>[],
    this.asSliver = false,
  });

  final Widget title;
  final List<Widget> actions;
  final bool asSliver;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;
    final Color backgroundColor = theme.colorScheme.surface;
    final Widget? leading =
        ModalRoute.of(context)?.canPop == true ? BackButton(color: theme.colorScheme.onSurface) : null;
    final DefaultTextStyle title = DefaultTextStyle(
      style: theme.textTheme.titleMedium!.copyWith(
        height: 1,
        fontWeight: FontWeight.w600,
      ),
      child: this.title,
    );

    if (asSliver) {
      return SliverAppBar(
        pinned: true,
        elevation: 0,
        backgroundColor: backgroundColor,
        leading: leading,
        centerTitle: false,
        title: title,
        actions: actions,
      );
    }

    return AppBar(
      elevation: 0,
      leading: leading,
      backgroundColor: backgroundColor,
      title: title,
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
