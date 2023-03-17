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

// TODO(Jogboms): improve tests w/ input form
void main() {
  group('CreateItemPage', () {
    final Finder createItemPage = find.byType(CreateItemPage);
    final NavigatorObserver navigatorObserver = MockNavigatorObserver();
    final TagViewModel dummyTag = TagEntity(
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

    setUpAll(() {
      registerFallbackValue(FakeRoute());
      registerFallbackValue(FakeCreateItemData());
    });

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const CreateItemPage(asModal: false)));

      await tester.pump();

      expect(createItemPage, findsOneWidget);
    });

    testWidgets('should create item and navigate to ItemDetail when not in modal mode', (WidgetTester tester) async {
      final MockItemProvider mockItemProvider = MockItemProvider();
      when(() => mockItemProvider.create(any())).thenAnswer((_) async => '1');

      await tester.pumpWidget(
        createApp(
          home: const CreateItemPage(asModal: false),
          observers: <NavigatorObserver>[navigatorObserver],
          overrides: <Override>[
            itemProvider.overrideWithValue(mockItemProvider),
            tagsProvider.overrideWith((_) => Stream<TagViewModelList>.value(dummyTagsList)),
          ],
        ),
      );

      await tester.pump();

      await tester.enterFieldsAndSubmit(mockItemProvider, dummyTag);

      await tester.verifyPushNavigation<TagDetailPage>(navigatorObserver);
    });

    testWidgets('should create item and navigate back when in modal mode', (WidgetTester tester) async {
      final MockItemProvider mockItemProvider = MockItemProvider();
      when(() => mockItemProvider.create(any())).thenAnswer((_) async => '1');

      await tester.pumpWidget(
        createApp(
          home: const CreateItemPage(asModal: true),
          observers: <NavigatorObserver>[navigatorObserver],
          overrides: <Override>[
            itemProvider.overrideWithValue(mockItemProvider),
            tagsProvider.overrideWith((_) => Stream<TagViewModelList>.value(dummyTagsList)),
          ],
        ),
      );

      await tester.pump();

      await tester.enterFieldsAndSubmit(mockItemProvider, dummyTag);

      await tester.verifyPopNavigation(navigatorObserver);
    });

    testWidgets('should handle error gracefully', (WidgetTester tester) async {
      final MockItemProvider mockItemProvider = MockItemProvider();
      when(() => mockItemProvider.create(any())).thenThrow(Exception());

      await tester.pumpWidget(
        createApp(
          home: const CreateItemPage(asModal: false),
          observers: <NavigatorObserver>[navigatorObserver],
          overrides: <Override>[
            itemProvider.overrideWithValue(mockItemProvider),
            tagsProvider.overrideWith((_) => Stream<TagViewModelList>.value(dummyTagsList)),
          ],
        ),
      );

      await tester.pump();

      await tester.enterFieldsAndSubmit(mockItemProvider, dummyTag);

      expect(tester.takeException(), null);
    });
  });
}

extension on WidgetTester {
  Future<void> enterFieldsAndSubmit(ItemProvider itemProvider, TagViewModel tag) async {
    await enterFields(tag);

    verify(
      () => itemProvider.create(
        CreateItemData(
          description: 'description',
          date: DateTime(1),
          tagId: '1',
          tagPath: 'path',
        ),
      ),
    ).called(1);
  }
}
