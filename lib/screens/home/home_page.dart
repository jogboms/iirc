import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';

import 'item_detail_page.dart';
import 'item_list_tile.dart';
import 'providers/items_provider.dart';

// TODO(Jogboms): Improve UI.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

@visibleForTesting
class HomePageState extends State<HomePage> {
  static const Key dataViewKey = Key('dataViewKey');
  static const Key loadingViewKey = Key('loadingViewKey');
  static const Key errorViewKey = Key('errorViewKey');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.brightness == Brightness.light ? Colors.grey.shade200 : Colors.grey.shade400,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) => ref.watch(filteredItemsStateProvider).when(
              data: (ItemModelList data) => _ItemsDataView(
                key: dataViewKey,
                items: data,
                onPressedItem: (ItemModel item) =>
                    Navigator.of(context).push<void>(ItemDetailPage.route(context, id: item.tag.id)),
              ),
              error: (Object error, _) => Center(
                key: errorViewKey,
                child: Text(error.toString()),
              ),
              loading: () => child!,
            ),
        child: const Center(
          key: loadingViewKey,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}

class _ItemsDataView extends StatelessWidget {
  const _ItemsDataView({super.key, required this.items, required this.onPressedItem});

  final ItemModelList items;
  final ValueChanged<ItemModel> onPressedItem;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        itemBuilder: (BuildContext context, int index) {
          final ItemModel item = items[index];

          return ItemListTile(
            key: Key(item.id),
            item: item,
            onPressed: () => onPressedItem(item),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: items.length,
      );
}
