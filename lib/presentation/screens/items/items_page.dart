import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/domain.dart';

import '../../models.dart';
import '../../state.dart';
import '../../utils.dart';
import '../../widgets.dart';
import '../tags/tag_detail_page.dart';
import 'items_tags_list_view.dart';
import 'providers/filtered_items_state_provider.dart';

class ItemsPage extends StatefulWidget {
  const ItemsPage({super.key});

  @override
  State<ItemsPage> createState() => ItemsPageState();
}

@visibleForTesting
class ItemsPageState extends State<ItemsPage> {
  static const Key dataViewKey = Key('dataViewKey');
  static const Key emptyDataViewKey = Key('emptyDataViewKey');

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) => ref.watch(filteredItemsStateProvider).when(
            data: (ItemViewModelList data) => _ItemsDataView(
              key: dataViewKey,
              items: data,
              analytics: ref.read(analyticsProvider),
            ),
            error: ErrorView.new,
            loading: () => child!,
          ),
      child: const LoadingView(),
    );
  }
}

class _ItemsDataView extends StatelessWidget {
  const _ItemsDataView({super.key, required this.items, required this.analytics});

  final ItemViewModelList items;
  final Analytics analytics;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        const CustomAppBar(
          title: SearchBar(),
          asSliver: true,
          centerTitle: true,
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            key: ItemsPageState.emptyDataViewKey,
            child: Center(
              child: Text(context.l10n.noItemsCreatedMessage),
            ),
          )
        else ...<Widget>[
          SliverToBoxAdapter(
            child: ItemsTagsListView(
              tags: items.map((ItemViewModel e) => e.tag),
              analytics: analytics,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 24),
            sliver: SliverList(
              delegate: SliverSeparatorBuilderDelegate(
                builder: (BuildContext context, int index) {
                  final ItemViewModel item = items[index];

                  return ItemListTile(
                    key: Key(item.id),
                    item: item,
                    onPressed: () {
                      analytics.log(AnalyticsEvent.itemClick('view tag: ${item.tag.id}'));
                      Navigator.of(context).push<void>(TagDetailPage.route(id: item.tag.id));
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                childCount: items.length,
              ),
            ),
          )
        ]
      ],
    );
  }
}
