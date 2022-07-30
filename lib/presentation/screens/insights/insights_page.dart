import 'package:flutter/material.dart';

import '../../theme/extensions.dart';
import '../../utils/extensions.dart';
import '../../widgets/custom_app_bar.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.menuPageBackgroundColor,
      child: CustomScrollView(
        slivers: <Widget>[
          CustomAppBar(
            title: Text(context.l10n.insightsCaption.capitalize()),
            asSliver: true,
            centerTitle: true,
          ),
        ],
      ),
    );
  }
}
