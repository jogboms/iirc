import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/widgets.dart';

class CreateTagPage extends StatefulWidget {
  const CreateTagPage({super.key});

  static PageRoute<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const CreateTagPage());
  }

  @override
  State<CreateTagPage> createState() => CreateTagPageState();
}

@visibleForTesting
class CreateTagPageState extends State<CreateTagPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: Text(context.l10n.createTag),
      ),
    );
  }
}
