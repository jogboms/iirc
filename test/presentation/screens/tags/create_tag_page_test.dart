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
  group('CreateTagPage', () {
    final Finder createTagPage = find.byType(CreateTagPage);
    final NavigatorObserver navigatorObserver = MockNavigatorObserver();

    setUpAll(() {
      registerFallbackValue(FakeRoute());
      registerFallbackValue(FakeCreateTagData());
    });

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const CreateTagPage(asModal: false)));

      await tester.pump();

      expect(createTagPage, findsOneWidget);
    });

    testWidgets('should create tag and navigate to TagDetail when not in modal mode', (WidgetTester tester) async {
      final MockTagProvider mockTagProvider = MockTagProvider();
      when(() => mockTagProvider.create(any())).thenAnswer((_) async => '1');

      await tester.pumpWidget(
        createApp(
          home: const CreateTagPage(asModal: false),
          observers: <NavigatorObserver>[navigatorObserver],
          overrides: <Override>[
            tagProvider.overrideWithValue(mockTagProvider),
          ],
        ),
      );

      await tester.pump();

      await tester.enterFieldsAndSubmit(mockTagProvider);

      await tester.verifyPushNavigation<TagDetailPage>(navigatorObserver);
    });

    testWidgets('should create tag and navigate back when in modal mode', (WidgetTester tester) async {
      final MockTagProvider mockTagProvider = MockTagProvider();
      when(() => mockTagProvider.create(any())).thenAnswer((_) async => '1');

      await tester.pumpWidget(
        createApp(
          home: const CreateTagPage(asModal: true),
          observers: <NavigatorObserver>[navigatorObserver],
          overrides: <Override>[
            tagProvider.overrideWithValue(mockTagProvider),
          ],
        ),
      );

      await tester.pump();

      await tester.enterFieldsAndSubmit(mockTagProvider);

      await tester.verifyPopNavigation(navigatorObserver);
    });

    testWidgets('should handle error gracefully', (WidgetTester tester) async {
      final MockTagProvider mockTagProvider = MockTagProvider();
      when(() => mockTagProvider.create(any())).thenThrow(Exception());

      await tester.pumpWidget(
        createApp(
          home: const CreateTagPage(asModal: false),
          observers: <NavigatorObserver>[navigatorObserver],
          overrides: <Override>[
            tagProvider.overrideWithValue(mockTagProvider),
          ],
        ),
      );

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
      () => tagProvider.create(
        const CreateTagData(
          title: 'title',
          description: 'description',
          color: 0xFFFFFFFF,
        ),
      ),
    ).called(1);
  }
}
