import 'package:flutter/material.dart';
import 'package:iirc/domain.dart';
import 'package:intl/intl.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../models.dart';
import '../screens/items/item_detail_page.dart';
import '../theme.dart';
import '../utils.dart';
import 'item_calendar_view.dart';
import 'item_list_tile.dart';

class ItemCalendarListView extends StatelessWidget {
  const ItemCalendarListView({super.key, required this.controller, required this.analytics});

  final ItemCalendarViewController controller;
  final Analytics analytics;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = context.theme;

    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? emptyView) {
        final ItemViewModelList items = controller.items;
        final int count = items.length;
        const EdgeInsets contentPadding = EdgeInsets.symmetric(horizontal: 16);

        return SliverPadding(
          padding: const EdgeInsets.only(top: 16, bottom: 48),
          sliver: MultiSliver(
            pushPinnedChildren: true,
            children: <Widget>[
              SliverPersistentHeader(
                pinned: true,
                delegate: _CustomSliverPersistentHeader(
                  child: SizedBox.expand(
                    child: Container(
                      padding: contentPadding,
                      child: DefaultTextStyle(
                        style: theme.textTheme.labelSmall!.copyWith(
                          fontWeight: AppFontWeight.bold,
                          letterSpacing: 1,
                          color: theme.appTheme.color.hintColor.shade600,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            if (controller.hasSelectedDate) ...<Widget>[
                              Text(DateFormat.EEEE().add_d().format(controller.selectedDate).toUpperCase()),
                              IconButton(
                                onPressed: () {
                                  analytics.log(AnalyticsEvent.buttonClick('clear date selection'));
                                  controller.clearSelection();
                                },
                                icon: const Icon(Icons.clear, size: 16),
                              ),
                            ] else
                              Text(context.l10n.entireMonth.toUpperCase()),
                            const Spacer(),
                            Text(context.l10n.itemsCountCaption(count).toUpperCase()),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (count == 0)
                emptyView!
              else
                SliverPadding(
                  padding: contentPadding.copyWith(top: 8),
                  sliver: SliverList(
                    delegate: SliverSeparatorBuilderDelegate(
                      builder: (BuildContext context, int index) {
                        final ItemViewModel item = items[index];

                        return ItemListTile(
                          key: Key(item.id),
                          item: item,
                          canShowDate: false,
                          onPressed: () {
                            analytics.log(AnalyticsEvent.itemClick('view item: ${item.id}'));
                            Navigator.of(context).push<void>(ItemDetailPage.route(id: item.id));
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, __) => const SizedBox(height: 8),
                      childCount: count,
                    ),
                  ),
                ),
            ],
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

class _CustomSliverPersistentHeader extends SliverPersistentHeaderDelegate {
  _CustomSliverPersistentHeader({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, _, bool overlapsContent) {
    final ThemeData theme = context.theme;
    return AnimatedPhysicalModel(
      duration: kThemeAnimationDuration,
      shape: BoxShape.rectangle,
      elevation: overlapsContent ? 4 : 0,
      shadowColor: theme.shadowColor,
      color: overlapsContent ? theme.colorScheme.surface : Colors.transparent,
      child: child,
    );
  }

  @override
  double get maxExtent => minExtent;

  @override
  double get minExtent => kToolbarHeight * .85;

  @override
  bool shouldRebuild(covariant _CustomSliverPersistentHeader oldDelegate) => child != oldDelegate.child;
}
