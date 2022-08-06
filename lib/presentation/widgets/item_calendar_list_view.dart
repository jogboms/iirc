import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models.dart';
import '../screens/home/item_detail_page.dart';
import '../theme.dart';
import '../utils.dart';
import 'item_calendar_view.dart';
import 'item_list_tile.dart';

class ItemCalendarListView extends StatelessWidget {
  const ItemCalendarListView({super.key, required this.controller});

  final ItemCalendarViewController controller;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return ValueListenableBuilder<DateTime>(
      valueListenable: controller,
      builder: (BuildContext context, DateTime focusedDay, Widget? emptyView) {
        final ItemViewModelList items = controller.items;
        final int count = items.length;

        if (count == 0) {
          return emptyView!;
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 48),
          sliver: SliverList(
            delegate: SliverSeparatorBuilderDelegate.withHeader(
              builder: (BuildContext context, int index) {
                final ItemViewModel item = items[index];

                return ItemListTile(
                  key: Key(item.id),
                  item: item,
                  canShowDate: false,
                  onPressed: () => Navigator.of(context).push<void>(ItemDetailPage.route(id: item.id)),
                );
              },
              separatorBuilder: (BuildContext context, __) => const SizedBox(height: 8),
              headerBuilder: (BuildContext context) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: DefaultTextStyle(
                  style: theme.textTheme.labelSmall!.copyWith(
                    fontWeight: AppFontWeight.bold,
                    letterSpacing: 1,
                    color: theme.appTheme.hintColor.shade600,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(DateFormat.yMMMEd().format(focusedDay).toUpperCase()),
                      Text(context.l10n.itemsCountCaption(count).toUpperCase()),
                    ],
                  ),
                ),
              ),
              childCount: count,
            ),
          ),
        );
      },
      child: SliverFillRemaining(
        child: Center(
          child: Text(context.l10n.noItemsAvailableMessage),
        ),
      ),
    );
  }
}
