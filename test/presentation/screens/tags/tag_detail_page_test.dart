import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../../utils.dart';

void main() {
  group('TagDetailPage', () {
    final Finder tagDetailPage = find.byType(TagDetailPage);

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
      final double devicePixelRatio = tester.binding.window.devicePixelRatio;
      tester.binding.window.devicePixelRatioTestValue = .25;
      addTearDown(() => tester.binding.window.devicePixelRatioTestValue = devicePixelRatio);

      final TagModel tag = TagsMockImpl.generateTag();
      final DateTime now = clock.now();
      final ItemViewModelList expectedItems = ItemViewModelList.generate(
        3,
        (_) => ItemsMockImpl.generateNormalizedItem(tag: tag, date: now).asViewModel,
      );

      await tester.pumpWidget(createApp(
        home: TagDetailPage(id: tag.id),
        overrides: <Override>[
          selectedTagStateProvider(tag.id).overrideWithValue(
            PreserveStateNotifier.withState<SelectedTagState>(
              AsyncData<SelectedTagState>(
                SelectedTagState(
                  tag: tag.asViewModel,
                  items: expectedItems,
                ),
              ),
            ),
          ),
        ],
      ));

      await tester.pump();

      for (final ItemViewModel item in expectedItems) {
        expect(find.byKey(Key(item.id)).descendantOf(tagDetailPage), findsOneWidget);
        expect(find.text(item.description), findsOneWidget);
      }
    });

    testWidgets('should show error if tags fetch fails', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      await tester.pumpWidget(createApp(
        home: const TagDetailPage(id: '1'),
        overrides: <Override>[
          selectedTagStateProvider('1').overrideWithValue(
            PreserveStateNotifier.withState<SelectedTagState>(
              AsyncError<SelectedTagState>(expectedError),
            ),
          ),
        ],
      ));

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorView).descendantOf(tagDetailPage), findsOneWidget);
      expect(find.text(expectedError.toString()).descendantOf(find.byType(ErrorView)), findsOneWidget);
    });
  });
}
