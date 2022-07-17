import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/widgets.dart';

class CreateItemPage extends StatefulWidget {
  const CreateItemPage({super.key});

  static PageRoute<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const CreateItemPage());
  }

  @override
  State<CreateItemPage> createState() => CreateItemPageState();
}

@visibleForTesting
class CreateItemPageState extends State<CreateItemPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.createItemCaption),
      ),
    );
  }
}
