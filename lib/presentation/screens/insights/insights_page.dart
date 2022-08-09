import 'package:flutter/material.dart';

import '../../utils.dart';
import '../../widgets.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        CustomAppBar(
          title: Text(context.l10n.insightsCaption.capitalize()),
          asSliver: true,
          centerTitle: true,
        ),
      ],
    );
  }
}
