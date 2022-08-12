// ignore_for_file: always_specify_types

import 'package:flutter/material.dart' show TabController;
import 'package:riverpod/riverpod.dart';

/// Container for MenuPageItem controller
/// Should be overridden per [ProviderScope]
final menuPageItemProvider = Provider.autoDispose<TabController>((_) => throw UnimplementedError());

enum MenuPageItem {
  items,
  calendar,
  insights,
  more;

  static const MenuPageItem defaultPage = calendar;
}

extension MenuPageTabControllerExtension on TabController {
  void navigateToItem(MenuPageItem item) {
    final int itemIndex = item.index;
    final int previousIndex = index;
    if ((previousIndex - itemIndex).abs() > 1) {
      index = itemIndex + (itemIndex > previousIndex ? -1 : 1);
    }

    animateTo(itemIndex);
  }
}
