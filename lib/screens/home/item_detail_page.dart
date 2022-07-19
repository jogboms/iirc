import 'package:flutter/material.dart';
import 'package:iirc/core.dart';
import 'package:iirc/widgets.dart';

class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key, required this.id});

  final String id;

  static PageRoute<void> route({required String id}) {
    return MaterialPageRoute<void>(builder: (_) => ItemDetailPage(id: id));
  }

  @override
  State<ItemDetailPage> createState() => ItemDetailPageState();
}

@visibleForTesting
class ItemDetailPageState extends State<ItemDetailPage> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          CustomAppBar(
            title: Text(context.l10n.informationCaption),
            actions: <Widget>[
              IconButton(
                onPressed: () {}, // TODO: delete item
                icon: const Icon(Icons.delete_forever),
                color: theme.colorScheme.error,
              ),
              const SizedBox(width: 4),
              IconButton(
                onPressed: () {}, // TODO: edit item
                icon: const Icon(Icons.edit),
                color: theme.colorScheme.onSurface,
              ),
              const SizedBox(width: 2),
            ],
            asSliver: true,
          )
        ],
      ),
    );
  }
}
