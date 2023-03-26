import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/domain.dart';

import '../../constants/app_routes.dart';
import '../../state.dart';
import '../../utils.dart';
import '../calendar/calendar_page.dart';
import '../insights/insights_page.dart';
import '../items/create_item_page.dart';
import '../items/items_page.dart';
import '../more/more_page.dart';
import 'menu_page_item_provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({
    super.key,
    this.initialPage = MenuPageItem.calendar,
  });

  final MenuPageItem initialPage;

  static PageRoute<void> route() {
    return MaterialPageRoute<void>(
      builder: (_) => const MenuPage(),
      settings: const RouteSettings(name: AppRoutes.menu),
    );
  }

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  static const Key dataViewKey = Key('dataViewKey');
  late final MenuPageController controller = MenuPageController(
    TabController(
      vsync: this,
      length: MenuPageItem.values.length,
      initialIndex: widget.initialPage.index,
    ),
  );

  @override
  Widget build(BuildContext context) => ProviderScope(
        overrides: <Override>[
          menuPageItemProvider.overrideWithValue(controller),
        ],
        child: Consumer(
          builder: (BuildContext context, WidgetRef ref, _) => MenuPageDataView(
            key: dataViewKey,
            l10n: context.l10n,
            analytics: ref.read(analyticsProvider),
            controller: ref.read(menuPageItemProvider).tabController,
          ),
        ),
      );
}

@visibleForTesting
class MenuPageDataView extends StatefulWidget {
  const MenuPageDataView({super.key, required this.l10n, required this.analytics, required this.controller});

  final L10n l10n;
  final Analytics analytics;
  final TabController controller;

  @override
  State<MenuPageDataView> createState() => MenuPageDataViewState();
}

@visibleForTesting
class MenuPageDataViewState extends State<MenuPageDataView> {
  static const Key fabKey = Key('fabKey');

  Map<MenuPageItem, TabRouteView> get tabRouteViews => <MenuPageItem, TabRouteView>{
        MenuPageItem.items: TabRouteView(
          widget.l10n.itemsCaption,
          const Icon(Icons.list_outlined),
          const ItemsPage(key: PageStorageKey<String>('items')),
        ),
        MenuPageItem.calendar: TabRouteView(
          widget.l10n.calendarCaption,
          const Icon(Icons.calendar_today_outlined),
          const CalendarPage(key: PageStorageKey<String>('calendar')),
        ),
        MenuPageItem.insights: TabRouteView(
          widget.l10n.insightsCaption,
          const Icon(Icons.insights_outlined),
          const InsightsPage(key: PageStorageKey<String>('insights')),
        ),
        MenuPageItem.more: TabRouteView(
          widget.l10n.moreCaption,
          const Icon(Icons.more_horiz),
          const MorePage(key: PageStorageKey<String>('more')),
        ),
      };

  late final Map<MenuPageItem, GlobalKey> destinationKeys = <MenuPageItem, GlobalKey>{
    for (MapEntry<MenuPageItem, TabRouteView> item in tabRouteViews.entries)
      item.key: GlobalKey(debugLabel: item.key.toString()),
  };

  int get currentIndex => widget.controller.index;

  @override
  void initState() {
    super.initState();

    widget.controller.addListener(_tabAnalyticLogger);
    _tabAnalyticLogger();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_tabAnalyticLogger);

    super.dispose();
  }

  void _tabAnalyticLogger() =>
      widget.analytics.setCurrentScreen('${AppRoutes.menu}/${MenuPageItem.values[currentIndex]}');

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: ValueListenableBuilder<double>(
        valueListenable: widget.controller.animation!,
        builder: (BuildContext context, double value, Widget? child) => Stack(
          children: <Widget>[
            for (MapEntry<MenuPageItem, TabRouteView> item in tabRouteViews.entries)
              Positioned(
                left: (item.key.index - value) * width,
                bottom: 0,
                top: 0,
                width: width,
                child: KeyedSubtree(
                  key: destinationKeys[item.key],
                  child: Material(
                    type: MaterialType.transparency,
                    child: tabRouteViews[item.key]!.widget,
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: widget.controller,
        builder: (BuildContext context, _) => BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (int index) => widget.controller.navigateToItem(MenuPageItem.values[index]),
          items: <BottomNavigationBarItem>[
            for (final TabRouteView item in tabRouteViews.values)
              BottomNavigationBarItem(
                icon: item.icon,
                label: item.title,
              ),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: widget.controller,
        builder: (BuildContext context, _) {
          final MenuPageItem menuItem = MenuPageItem.values[currentIndex];
          final Route<void> Function(Object)? routeBuilder = menuItem.floatingActionButtonRouteBuilder;

          return AnimatedScale(
            scale: routeBuilder != null ? 1 : 0,
            duration: const Duration(milliseconds: 250),
            child: Consumer(
              builder: (BuildContext context, WidgetRef ref, _) => FloatingActionButton(
                key: fabKey,
                onPressed: () {
                  widget.analytics.log(AnalyticsEvent.buttonClick('create item: $menuItem'));
                  Navigator.of(context).push<void>(
                    routeBuilder!(ref.read(calendarStateProvider)),
                  );
                },
                child: const Icon(Icons.add_outlined),
              ),
            ),
          );
        },
      ),
    );
  }
}

@visibleForTesting
class TabRouteView {
  const TabRouteView(this.title, this.icon, this.widget);

  final String title;
  final Widget icon;
  final Widget widget;
}

extension on MenuPageItem {
  Route<void> Function(Object param)? get floatingActionButtonRouteBuilder {
    switch (this) {
      case MenuPageItem.calendar:
        return (Object date) => CreateItemPage.route(asModal: true, date: date as DateTime);
      case MenuPageItem.items:
        return (_) => CreateItemPage.route();
      case MenuPageItem.insights:
      case MenuPageItem.more:
        return null;
    }
  }
}
