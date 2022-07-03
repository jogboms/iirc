import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/domain.dart';

import 'selected_item_provider.dart';

class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key});

  static Future<void> go(BuildContext context) {
    return Navigator.of(context).push<void>(MaterialPageRoute<void>(builder: (_) => const ItemDetailPage()));
  }

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) {
          final ItemModel? item = ref.read(selectedItemProvider);

          if (item == null) {
            return const Center(
              child: Text('No item'),
            );
          }

          return Text(item.id);
        },
      ),
    );
  }
}
