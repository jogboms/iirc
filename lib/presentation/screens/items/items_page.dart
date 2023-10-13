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
      builder: (BuildContext context, WidgetRef ref, Widget? child) => ref.watch(filteredItemsProvider).when(
            skipLoadingOnReload: true,
            data: (FilteredItemsState state) => _ItemsDataView(
              key: dataViewKey,
              tags: state.tags,
              items: state.items,
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
  const _ItemsDataView({super.key, required this.tags, required this.items, required this.analytics});

  final TagViewModelList tags;
  final ItemViewModelList items;
  final Analytics analytics;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        const CustomAppBar(
          title: AppSearchBar(),
          asSliver: true,
          centerTitle: true,
        ),
        SliverToBoxAdapter(
          child: ItemsTagsListView(
            tags: tags,
            analytics: analytics,
          ),
        ),
        if (items.isEmpty)
          SliverFillRemaining(
            key: ItemsPageState.emptyDataViewKey,
            child: Center(
              child: Text(context.l10n.noItemsCreatedMessage),
            ),
          )
        else ...<Widget>[
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
          ),
        ],
      ],
    );
  }
}
