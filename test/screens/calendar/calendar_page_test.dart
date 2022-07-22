import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/screens.dart';
import 'package:iirc/widgets.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

// TODO: improve tests w/ calendar day selection
void main() {
  group('CalendarPage', () {
    final Finder calendarPage = find.byType(CalendarPage);

    setUp(() {
      when(() => mockRepositories.auth.onAuthStateChanged).thenAnswer((_) => Stream<String>.value('1'));
      when(() => mockRepositories.auth.account).thenAnswer((_) async => AuthMockImpl.generateAccount());
      when(() => mockRepositories.users.fetch(any())).thenAnswer((_) async => UsersMockImpl.user);
    });

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const CalendarPage()));

      await tester.pump();

      expect(calendarPage, findsOneWidget);
    });

    testWidgets('should show loading view on load', (WidgetTester tester) async {
      when(() => mockRepositories.items.fetch(any())).thenAnswer((_) async* {});

      await tester.pumpWidget(createApp(home: const CalendarPage()));

      await tester.pump();

      expect(find.byType(LoadingView).descendantOf(calendarPage), findsOneWidget);
    });

    testWidgets('should show list of items for date', (WidgetTester tester) async {
      final TagModel tag = TagsMockImpl.generateTag();
      final DateTime now = clock.now();
      final ItemModelList expectedItems = ItemModelList.generate(
        3,
        (_) => ItemsMockImpl.generateItem(tag: tag, date: now),
      );

      when(() => mockRepositories.items.fetch(any())).thenAnswer((_) => Stream<ItemModelList>.value(expectedItems));

      await tester.pumpWidget(createApp(home: const CalendarPage()));

      await tester.pump();
      await tester.pump();

      for (final ItemModel item in expectedItems) {
        final Finder itemWidget = find.byKey(Key(item.id));
        expect(itemWidget.descendantOf(calendarPage), findsOneWidget);
        expect(find.text(item.description).descendantOf(itemWidget), findsOneWidget);
        expect(find.text(item.tag.title.capitalize()).descendantOf(itemWidget), findsOneWidget);
      }
    });

    testWidgets('should show error if any', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      when(() => mockRepositories.items.fetch(any())).thenAnswer(
        (_) => Stream<ItemModelList>.error(expectedError),
      );

      await tester.pumpWidget(createApp(home: const CalendarPage()));

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorView).descendantOf(calendarPage), findsOneWidget);
      expect(find.text(expectedError.toString()).descendantOf(find.byType(ErrorView)), findsOneWidget);
    });
  });
}
