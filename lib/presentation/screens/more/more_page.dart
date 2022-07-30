import 'package:flutter/material.dart';

import '../../theme/extensions.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_app_bar.dart';
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
      color: context.theme.menuPageBackgroundColor,
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
