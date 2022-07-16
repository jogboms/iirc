import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/widgets.dart';

import 'item_list_tile.dart';
import 'providers/selected_items_provider.dart';

class ItemDetailPage extends StatefulWidget {
  const ItemDetailPage({super.key, required this.id});

  final String id;

  static PageRoute<void> route(BuildContext context, {required String id}) {
    return MaterialPageRoute<void>(builder: (_) => ItemDetailPage(id: id));
  }

  @override
  State<ItemDetailPage> createState() => ItemDetailPageState();
}

@visibleForTesting
class ItemDetailPageState extends State<ItemDetailPage> {
  static const Key dataViewKey = Key('dataViewKey');
  static const Key loadingViewKey = Key('loadingViewKey');
  static const Key errorViewKey = Key('errorViewKey');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) =>
            ref.watch(selectedItemsStateProvider(widget.id)).when(
                  data: (SelectedItemState state) => _SelectedItemDataView(
                    key: dataViewKey,
                    tag: state.tag,
                    items: state.items,
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

class _SelectedItemDataView extends StatelessWidget {
  const _SelectedItemDataView({super.key, required this.tag, required this.items});

  final TagModel tag;
  final ItemModelList items;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          pinned: true,
          elevation: 0,
          backgroundColor: theme.colorScheme.surface,
          leading: BackButton(color: theme.colorScheme.onSurface),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const SizedBox(height: 24),
                      Text(
                        tag.title,
                        style: theme.textTheme.headlineMedium?.copyWith(height: 1),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tag.description,
                        style: theme.textTheme.labelLarge,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                TagColorBox.large(key: ValueKey<int>(tag.color), code: tag.color),
              ],
            ),
          ),
        ),
        // TODO(Jogboms): Replace with a calendar.
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final ItemModel item = items[index];

                return ItemListTile(key: Key(item.id), item: item);
              },
              childCount: items.length,
            ),
          ),
        ),
      ],
    );
  }
}
