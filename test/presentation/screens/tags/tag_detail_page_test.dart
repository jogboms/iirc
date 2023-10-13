import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../../mocks.dart';
import '../../../utils.dart';

void main() {
  group('TagDetailPage', () {
    final Finder tagDetailPage = find.byType(TagDetailPage);
    final NavigatorObserver navigatorObserver = MockNavigatorObserver();

    setUpAll(() {
      registerFallbackValue(FakeRoute());
    });

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const TagDetailPage(id: '1')));

      await tester.pump();

      expect(tagDetailPage, findsOneWidget);
    });

    testWidgets('should show loading view on load', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const TagDetailPage(id: '1')));

      await tester.pump();

      expect(find.byType(LoadingView).descendantOf(tagDetailPage), findsOneWidget);
    });

    testWidgets('should show list of items for tag', (WidgetTester tester) async {
      final double devicePixelRatio = tester.view.devicePixelRatio;
      tester.view.devicePixelRatio = .25;
      addTearDown(() => tester.view.devicePixelRatio = devicePixelRatio);

      final TagEntity tag = TagsMockImpl.generateTag();
      final DateTime now = clock.now();
      final ItemViewModelList expectedItems = ItemViewModelList.generate(
        3,
        (_) => ItemsMockImpl.generateNormalizedItem(tag: tag, date: now).asViewModel,
      );

      await tester.pumpWidget(
        createApp(
          home: TagDetailPage(id: tag.id),
          overrides: <Override>[
            selectedTagProvider(tag.id).overrideWith(
              (_) async => SelectedTagState(
                tag: tag.asViewModel,
                items: expectedItems,
              ),
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.pump();

      for (final ItemViewModel item in expectedItems) {
        expect(find.byKey(Key(item.id)).descendantOf(tagDetailPage), findsOneWidget);
        expect(find.text(item.description), findsOneWidget);
      }
    });

    testWidgets('should navigate to create item screen on create button tap', (WidgetTester tester) async {
      final TagEntity tag = TagsMockImpl.generateTag();

      await tester.pumpWidget(
        createApp(
          home: TagDetailPage(id: tag.id),
          overrides: <Override>[
            selectedTagProvider(tag.id).overrideWith(
              (_) async => SelectedTagState(
                tag: tag.asViewModel,
                items: ItemViewModelList.empty(),
              ),
            ),
          ],
          observers: <NavigatorObserver>[navigatorObserver],
        ),
      );

      await tester.pump();
      await tester.pump();

      await tester.tap(find.byKey(TagDetailPageState.createItemButtonKey));

      await tester.verifyPushNavigation<CreateItemPage>(navigatorObserver);
    });

    testWidgets('should navigate to update item screen on update button tap', (WidgetTester tester) async {
      final TagEntity tag = TagsMockImpl.generateTag();

      await tester.pumpWidget(
        createApp(
          home: TagDetailPage(id: tag.id),
          overrides: <Override>[
            selectedTagProvider(tag.id).overrideWith(
              (_) async => SelectedTagState(
                tag: tag.asViewModel,
                items: ItemViewModelList.empty(),
              ),
            ),
          ],
          observers: <NavigatorObserver>[navigatorObserver],
        ),
      );

      await tester.pump();
      await tester.pump();

      await tester.tap(find.byKey(SelectedTagDataViewState.updateItemButtonKey));

      await tester.verifyPushNavigation<UpdateTagPage>(navigatorObserver);
    });

    testWidgets('should show error if tags fetch fails', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      await tester.pumpWidget(
        createApp(
          home: const TagDetailPage(id: '1'),
          overrides: <Override>[
            selectedTagProvider('1').overrideWith(
              (_) async => throw expectedError,
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorView).descendantOf(tagDetailPage), findsOneWidget);
      expect(find.text(expectedError.toString()).descendantOf(find.byType(ErrorView)), findsOneWidget);
    });
  });
}
