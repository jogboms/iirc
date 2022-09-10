import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../../mocks.dart';
import '../../../utils.dart';
import 'utils.dart';

void main() {
  group('UpdateItemPage', () {
    final Finder updateItemPage = find.byType(UpdateItemPage);
    final NavigatorObserver navigatorObserver = MockNavigatorObserver();
    final TagViewModel dummyTag = TagModel(
      id: '1',
      color: 0xF,
      description: 'description',
      title: 'title',
      path: 'path',
      createdAt: DateTime(0),
      updatedAt: null,
    ).asViewModel;
    final TagViewModelList dummyTagsList = <TagViewModel>[
      dummyTag,
      ...TagViewModelList.generate(3, (_) => TagsMockImpl.generateTag().asViewModel),
    ];
    final ItemViewModel dummyItem = ItemsMockImpl.generateNormalizedItem(id: '1', tag: dummyTag).asViewModel;

    setUpAll(() {
      registerFallbackValue(FakeRoute());
      registerFallbackValue(FakeUpdateItemData());
    });

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: UpdateItemPage(item: dummyItem)));

      await tester.pump();

      expect(updateItemPage, findsOneWidget);
    });

    testWidgets('should update item and navigate back', (WidgetTester tester) async {
      final MockItemProvider mockItemProvider = MockItemProvider();
      when(() => mockItemProvider.update(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(
        createApp(
          home: UpdateItemPage(item: dummyItem),
          observers: <NavigatorObserver>[navigatorObserver],
          overrides: <Override>[
            itemProvider.overrideWithValue(mockItemProvider),
            tagsProvider.overrideWithValue(AsyncData<TagViewModelList>(dummyTagsList)),
          ],
        ),
      );

      await tester.pump();

      await tester.enterFieldsAndSubmit(mockItemProvider, dummyItem, dummyTag);

      await tester.verifyPopNavigation(navigatorObserver);
    });

    testWidgets('should handle error gracefully', (WidgetTester tester) async {
      final MockItemProvider mockItemProvider = MockItemProvider();
      when(() => mockItemProvider.update(any())).thenThrow(Exception());

      await tester.pumpWidget(
        createApp(
          home: UpdateItemPage(item: dummyItem),
          observers: <NavigatorObserver>[navigatorObserver],
          overrides: <Override>[
            itemProvider.overrideWithValue(mockItemProvider),
            tagsProvider.overrideWithValue(AsyncData<TagViewModelList>(dummyTagsList)),
          ],
        ),
      );

      await tester.pump();

      await tester.enterFieldsAndSubmit(mockItemProvider, dummyItem, dummyTag);

      expect(tester.takeException(), null);
    });
  });
}

extension on WidgetTester {
  Future<void> enterFieldsAndSubmit(ItemProvider itemProvider, ItemViewModel item, TagViewModel tag) async {
    await enterFields(tag);

    verify(
      () => itemProvider.update(
        UpdateItemData(
          id: item.id,
          path: item.path,
          description: 'description',
          date: DateTime(1),
          tag: TagModelReference(id: tag.id, path: tag.path),
        ),
      ),
    ).called(1);
  }
}
