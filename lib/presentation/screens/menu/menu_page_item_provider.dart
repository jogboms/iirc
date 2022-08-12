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

  @override
  String toString() => name;
}

extension MenuPageTabControllerExtension on TabController {
  void navigateToItem(MenuPageItem item) => index = item.index;
}
