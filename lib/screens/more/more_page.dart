import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/widgets.dart';

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
      child: CustomScrollView(
        slivers: <Widget>[
          CustomAppBar(
            title: Text(context.l10n.moreCaption.capitalize()),
            asSliver: true,
            centerTitle: true,
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                const LogoutListTile(),
              ]),
            ),
          )
        ],
      ),
    );
  }
}
