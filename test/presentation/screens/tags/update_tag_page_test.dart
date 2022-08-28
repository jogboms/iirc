import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../../mocks.dart';
import '../../../utils.dart';
import 'utils.dart';

void main() {
  group('UpdateTagPage', () {
    final Finder updateTagPage = find.byType(UpdateTagPage);
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

    setUpAll(() {
      registerFallbackValue(FakeRoute());
      registerFallbackValue(FakeUpdateTagData());
    });

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: UpdateTagPage(tag: dummyTag)));

      await tester.pump();

      expect(updateTagPage, findsOneWidget);
    });

    testWidgets('should update tag and navigate back', (WidgetTester tester) async {
      final MockTagProvider mockTagProvider = MockTagProvider();
      when(() => mockTagProvider.update(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(createApp(
        home: UpdateTagPage(tag: dummyTag),
        observers: <NavigatorObserver>[navigatorObserver],
        overrides: <Override>[
          tagProvider.overrideWithValue(mockTagProvider),
        ],
      ));

      await tester.pump();

      await tester.enterFieldsAndSubmit(mockTagProvider);

      await tester.verifyPopNavigation(navigatorObserver);
    });

    testWidgets('should handle error gracefully', (WidgetTester tester) async {
      final MockTagProvider mockTagProvider = MockTagProvider();
      when(() => mockTagProvider.update(any())).thenThrow(Exception());

      await tester.pumpWidget(createApp(
        home: UpdateTagPage(tag: dummyTag),
        observers: <NavigatorObserver>[navigatorObserver],
        overrides: <Override>[
          tagProvider.overrideWithValue(mockTagProvider),
        ],
      ));

      await tester.pump();

      await tester.enterFieldsAndSubmit(mockTagProvider);

      expect(tester.takeException(), null);
    });
  });
}

extension on WidgetTester {
  Future<void> enterFieldsAndSubmit(TagProvider tagProvider) async {
    await enterFields();

    verify(
      () => tagProvider.update(const UpdateTagData(
        id: '1',
        path: 'path',
        title: 'title',
        description: 'description',
        color: 0xFFFFFFFF,
      )),
    ).called(1);
  }
}
