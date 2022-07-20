import 'package:flutter/material.dart';
import 'package:iirc/core.dart';

import 'logout_list_tile.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.brightness == Brightness.light ? Colors.grey.shade200 : Colors.grey.shade400,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const <Widget>[
            LogoutListTile(),
          ],
        ),
      ),
    );
  }
}
