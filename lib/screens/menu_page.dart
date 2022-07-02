import 'package:flutter/material.dart';
import 'package:iirc/core.dart';

import 'home_page.dart';
import 'tags_page.dart';

enum MenuPageItem {
  tags,
  items,
  more;

  static const MenuPageItem defaultPage = items;
}

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  Map<MenuPageItem, _TabRouteView> get _tabRouteViews => <MenuPageItem, _TabRouteView>{
        MenuPageItem.tags: _TabRouteView(
          S.current.tagsCaption,
          const Icon(Icons.tag),
          const TagsPage(key: PageStorageKey<String>('tags')),
        ),
        MenuPageItem.items: _TabRouteView(
          S.current.itemsCaption,
          const Icon(Icons.all_inclusive),
          const HomePage(key: PageStorageKey<String>('items')),
        ),
        MenuPageItem.more: _TabRouteView(
          S.current.moreCaption,
          const Icon(Icons.more_horiz),
          Container(key: const PageStorageKey<String>('more'), color: Colors.grey),
        ),
      };

  late final TabController _controller = MenuPageProvider.of(context).data..addListener(_pageListener);
  late final Map<MenuPageItem, GlobalKey> _destinationKeys = <MenuPageItem, GlobalKey>{
    for (MapEntry<MenuPageItem, _TabRouteView> item in _tabRouteViews.entries)
      item.key: GlobalKey(debugLabel: item.key.toString()),
  };

  late int _currentPageIndex = _controller.index;

  @override
  void dispose() {
    _controller.removeListener(_pageListener);
    super.dispose();
  }

  void _pageListener() {
    if (!_controller.indexIsChanging) {
      setState(() => _currentPageIndex = _controller.index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appName),
      ),
      body: AnimatedBuilder(
        animation: _controller.animation!,
        builder: (BuildContext context, Widget? child) {
          final double value = _controller.animation!.value;

          return Stack(
            children: <Widget>[
              for (MapEntry<MenuPageItem, _TabRouteView> item in _tabRouteViews.entries)
                Positioned(
                  left: (item.key.index - value) * width,
                  bottom: 0,
                  top: 0,
                  width: width,
                  child: KeyedSubtree(
                    key: _destinationKeys[item.key],
                    child: Material(
                      type: MaterialType.transparency,
                      child: _tabRouteViews[item.key]!.widget,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentPageIndex,
        onTap: (int index) {
          final MenuPageItem item = MenuPageItem.values[index];
          if (_currentPageIndex == index) {
            return;
          }
          if ((_currentPageIndex - index).abs() > 1) {
            _controller.index = index + (index > _currentPageIndex ? -1 : 1);
          }
          _controller.navigate(item);
        },
        items: <BottomNavigationBarItem>[
          for (final _TabRouteView item in _tabRouteViews.values)
            BottomNavigationBarItem(icon: item.icon, label: item.title),
        ],
      ),
    );
  }
}

class MenuPageProvider extends InheritedWidget {
  const MenuPageProvider({
    super.key,
    required this.data,
    required super.child,
  });

  final TabController data;

  static MenuPageProvider of(BuildContext context) {
    final MenuPageProvider? result = context.dependOnInheritedWidgetOfExactType<MenuPageProvider>();
    assert(result != null, 'No MenuPageProvider found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant MenuPageProvider oldWidget) => data.animation != oldWidget.data.animation;
}

extension TabControllerExtension on TabController {
  void navigate(MenuPageItem item) => animateTo(item.index);
}

class _TabRouteView {
  const _TabRouteView(this.title, this.icon, this.widget);

  final String title;
  final Widget icon;
  final Widget widget;
}
