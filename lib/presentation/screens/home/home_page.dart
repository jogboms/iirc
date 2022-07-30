import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/item_view_model.dart';
import '../../theme/extensions.dart';
import '../../utils/extensions.dart';
import '../../utils/sliver_separator_builder_delegate.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/error_view.dart';
import '../../widgets/item_list_tile.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/search_bar.dart';
import '../tags/tag_detail_page.dart';
import 'providers/filtered_items_state_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => HomePageState();
}

@visibleForTesting
class HomePageState extends State<HomePage> {
  static const Key dataViewKey = Key('dataViewKey');
  static const Key emptyDataViewKey = Key('emptyDataViewKey');

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.theme.menuPageBackgroundColor,
      child: Consumer(
        builder: (BuildContext context, WidgetRef ref, Widget? child) => ref.watch(filteredItemsStateProvider).when(
              data: (ItemViewModelList data) => _ItemsDataView(key: dataViewKey, items: data),
              error: ErrorView.new,
              loading: () => child!,
            ),
        child: const LoadingView(),
      ),
    );
  }
}

class _ItemsDataView extends StatelessWidget {
  const _ItemsDataView({super.key, required this.items});

  final ItemViewModelList items;

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
            key: HomePageState.emptyDataViewKey,
            child: Center(
              child: Text(context.l10n.noItemsCreatedMessage),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            sliver: SliverList(
              delegate: SliverSeparatorBuilderDelegate(
                builder: (BuildContext context, int index) {
                  final ItemViewModel item = items[index];

                  return ItemListTile(
                    key: Key(item.id),
                    item: item,
                    onPressed: () => Navigator.of(context).push<void>(TagDetailPage.route(id: item.tag.id)),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 8),
                childCount: items.length,
              ),
            ),
          )
      ],
    );
  }
}
