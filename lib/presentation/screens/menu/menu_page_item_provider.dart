import 'package:flutter/material.dart' show TabController;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'menu_page_item_provider.g.dart';

/// Container for MenuPageItem controller
/// Should be overridden per [ProviderScope]
@Riverpod(dependencies: <Object>[])
MenuPageController menuPageItem(MenuPageItemRef ref) => throw UnimplementedError();

/// This wrapper class only exists because riverpod generator doesn't support ChangeNotifiers (TabController) directly
class MenuPageController {
  const MenuPageController(this.tabController);

  final TabController tabController;
}

enum MenuPageItem {
  items,
  calendar,
  insights,
  more;

  @override
  String toString() => name;
}

extension MenuPageTabControllerExtension on TabController {
  void navigateToItem(MenuPageItem item) => index = item.index;
}
