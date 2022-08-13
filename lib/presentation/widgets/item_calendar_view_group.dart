import 'package:flutter/widgets.dart';
import 'package:iirc/domain.dart';
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
    required this.analytics,
  });

  final bool primary;
  final ItemViewModelList items;
  final ItemCalendarViewController controller;
  final Analytics analytics;

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
            analytics: analytics,
          ),
        ],
      );
}
