import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../../utils.dart';

// TODO(Jogboms): improve tests w/ calendar day selection
void main() {
  group('CalendarPage', () {
    final Finder calendarPage = find.byType(CalendarPage);

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const CalendarPage()));

      await tester.pump();

      expect(calendarPage, findsOneWidget);
    });

    testWidgets('should show loading view on load', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const CalendarPage()));

      await tester.pump();

      expect(find.byType(LoadingView).descendantOf(calendarPage), findsOneWidget);
    });

    testWidgets('should show list of items for date', (WidgetTester tester) async {
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
          home: const CalendarPage(),
          overrides: <Override>[
            itemsProvider.overrideWith(
              (_) => Stream<ItemViewModelList>.value(expectedItems),
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.pump();

      for (final ItemViewModel item in expectedItems) {
        final Finder itemWidget = find.byKey(Key(item.id));
        expect(itemWidget.descendantOf(calendarPage), findsOneWidget);
        expect(find.text(item.description).descendantOf(itemWidget), findsOneWidget);
        expect(find.text(item.tag.title.capitalize()).descendantOf(itemWidget), findsOneWidget);
      }
    });

    testWidgets('should show error if any', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      await tester.pumpWidget(
        createApp(
          home: const CalendarPage(),
          overrides: <Override>[
            itemsProvider.overrideWith(
              (_) => Stream<ItemViewModelList>.error(expectedError),
            ),
          ],
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorView).descendantOf(calendarPage), findsOneWidget);
      expect(find.text(expectedError.toString()).descendantOf(find.byType(ErrorView)), findsOneWidget);
    });
  });
}
