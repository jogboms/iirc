import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../../mocks.dart';
import '../../../utils.dart';

void main() {
  group('MenuPage', () {
    final Finder menuPage = find.byType(MenuPage);
    final NavigatorObserver navigatorObserver = MockNavigatorObserver();

    setUpAll(() {
      registerFallbackValue(FakeRoute());
    });

    tearDown(() {
      reset(navigatorObserver);
    });

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpPage(navigatorObserver: navigatorObserver);

      expect(menuPage, findsOneWidget);
      expect(find.byType(ItemsPage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(CalendarPage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(InsightsPage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(MorePage).descendantOf(menuPage), findsOneWidget);
    });

    testWidgets('should update current page index on navigate', (WidgetTester tester) async {
      await tester.pumpPage(navigatorObserver: navigatorObserver);

      final MenuPageDataViewState state = tester.firstState<MenuPageDataViewState>(find.byType(MenuPageDataView));
      for (final MapEntry<MenuPageItem, TabRouteView> entry in state.tabRouteViews.entries) {
        await tester.tap(find.text(entry.value.title));
        expect(state.currentIndex, entry.key.index);
      }
    });

    testWidgets('should navigate to CreateItemPage (by default) on FAB action', (WidgetTester tester) async {
      await tester.pumpPage(navigatorObserver: navigatorObserver);

      await tester.tap(find.byType(FloatingActionButton));

      await tester.verifyPushNavigation<CreateItemPage>(navigatorObserver);
    });

    testWidgets('should navigate to CreateItemPage from items page on FAB action', (WidgetTester tester) async {
      await tester.pumpPage(navigatorObserver: navigatorObserver, initialPage: MenuPageItem.items);

      await tester.tap(find.byKey(MenuPageDataViewState.fabKey));
      await tester.verifyPushNavigation<CreateItemPage>(navigatorObserver);
    });
  });
}

extension on WidgetTester {
  Future<void> pumpPage({
    required NavigatorObserver navigatorObserver,
    MenuPageItem initialPage = MenuPageItem.calendar,
  }) =>
      pumpWidget(createApp(
        home: MenuPage(initialPage: initialPage),
        observers: <NavigatorObserver>[navigatorObserver],
        overrides: <Override>[
          tagsProvider.overrideWithValue(AsyncData<TagViewModelList>(TagViewModelList.empty())),
          itemsProvider.overrideWithValue(AsyncData<ItemViewModelList>(ItemViewModelList.empty())),
        ],
      )).then((_) => pump());
}
