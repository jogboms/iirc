import 'package:flutter/material.dart';
import 'package:iirc/core.dart';

class MenuPageContainer extends StatelessWidget {
  const MenuPageContainer({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Material(
        color: context.theme.brightness == Brightness.light ? Colors.grey.shade200 : Colors.grey.shade400,
        child: child,
      );
}
