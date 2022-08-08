import 'package:flutter/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../models.dart';
import 'item_calendar_list_view.dart';
import 'item_calendar_view.dart';
import 'item_calendar_view_header.dart';

class ItemCalendarViewGroup extends StatelessWidget {
  const ItemCalendarViewGroup({
    super.key,
    this.primary = false,
    required this.controller,
    required this.items,
  });

  final bool primary;
  final ItemViewModelList items;
  final ItemCalendarViewController controller;

  @override
  Widget build(BuildContext context) => MultiSliver(
        pushPinnedChildren: true,
        children: <Widget>[
          ItemCalendarViewHeader(
            controller: controller,
            primary: primary,
          ),
          ItemCalendarView(
            controller: controller,
            items: items,
          ),
          ItemCalendarListView(
            controller: controller,
          ),
        ],
      );
}
