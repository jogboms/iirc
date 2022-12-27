import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../../mocks.dart';
import '../../../utils.dart';

void main() {
  group('ItemsPage', () {
    final Finder itemsPage = find.byType(ItemsPage);
    final NavigatorObserver navigatorObserver = MockNavigatorObserver();

    setUpAll(() {
      registerFallbackValue(FakeRoute());
    });

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const ItemsPage()));

      await tester.pump();

      expect(itemsPage, findsOneWidget);
    });

    testWidgets('should show loading view on load', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const ItemsPage()));

      await tester.pump();

      expect(find.byType(LoadingView).descendantOf(itemsPage), findsOneWidget);
    });

    testWidgets('should show empty view', (WidgetTester tester) async {
      await tester.pumpWidget(
        createApp(
          home: const ItemsPage(),
          overrides: <Override>[
            tagsProvider.overrideWithValue(
              AsyncData<TagViewModelList>(TagViewModelList.empty()),
            ),
            itemsProvider.overrideWithValue(
              AsyncData<ItemViewModelList>(ItemViewModelList.empty()),
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byKey(ItemsPageState.emptyDataViewKey).descendantOf(itemsPage), findsOneWidget);
    });

    testWidgets('should show list of tags', (WidgetTester tester) async {
      final TagViewModelList expectedTags = TagViewModelList.generate(
        3,
        (_) => TagsMockImpl.generateTag().asViewModel,
      );

      await tester.pumpWidget(
        createApp(
          home: const ItemsPage(),
          overrides: <Override>[
            tagsProvider.overrideWithValue(
              AsyncData<TagViewModelList>(expectedTags),
            ),
            itemsProvider.overrideWithValue(
              AsyncData<ItemViewModelList>(ItemViewModelList.empty()),
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.pump();

      // Find all tags
      for (final TagViewModel tag in expectedTags) {
        expect(find.byKey(Key(tag.id)).descendantOf(itemsPage), findsOneWidget);
        expect(find.text('#${tag.title.capitalize()}'), findsOneWidget);
      }
    });

    testWidgets('should show unique list of items', (WidgetTester tester) async {
      final TagEntity tag = TagsMockImpl.generateTag();
      final ItemViewModelList expectedItems = ItemViewModelList.generate(
        3,
        (int index) =>
            (index.isEven ? ItemsMockImpl.generateNormalizedItem() : ItemsMockImpl.generateNormalizedItem(tag: tag))
                .asViewModel,
      );
      final Set<TagEntity> uniqueTags = expectedItems.uniqueBy((ItemViewModel element) => element.tag);

      await tester.pumpWidget(
        createApp(
          home: const ItemsPage(),
          overrides: <Override>[
            tagsProvider.overrideWithValue(
              AsyncData<TagViewModelList>(TagViewModelList.empty()),
            ),
            itemsProvider.overrideWithValue(
              AsyncData<ItemViewModelList>(expectedItems),
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.pump();

      // Find all items
      for (final TagEntity tag in uniqueTags) {
        final ItemViewModel item = expectedItems.firstWhere((ItemViewModel element) => element.tag.id == tag.id);
        expect(find.byKey(Key(item.id)).descendantOf(itemsPage), findsOneWidget);
        expect(find.text(item.description), findsOneWidget);
        expect(find.text(item.tag.title.capitalize()), findsOneWidget);
      }
    });

    testWidgets('should navigate to tag detail screen on item tap', (WidgetTester tester) async {
      final ItemViewModel item = ItemsMockImpl.generateNormalizedItem().asViewModel;

      await tester.pumpWidget(
        createApp(
          home: const ItemsPage(),
          overrides: <Override>[
            tagsProvider.overrideWithValue(
              AsyncData<TagViewModelList>(TagViewModelList.empty()),
            ),
            itemsProvider.overrideWithValue(
              AsyncData<ItemViewModelList>(<ItemViewModel>[item]),
            ),
          ],
          observers: <NavigatorObserver>[navigatorObserver],
        ),
      );

      await tester.pump();
      await tester.pump();

      await tester.tap(find.byKey(Key(item.id)));

      await tester.verifyPushNavigation<TagDetailPage>(navigatorObserver);
    });

    testWidgets('should show error if any', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      await tester.pumpWidget(
        createApp(
          home: const ItemsPage(),
          overrides: <Override>[
            tagsProvider.overrideWithValue(
              AsyncData<TagViewModelList>(TagViewModelList.empty()),
            ),
            itemsProvider.overrideWithValue(
              AsyncError<ItemViewModelList>(expectedError),
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorView).descendantOf(itemsPage), findsOneWidget);
      expect(find.text(expectedError.toString()).descendantOf(find.byType(ErrorView)), findsOneWidget);
    });
  });
}
