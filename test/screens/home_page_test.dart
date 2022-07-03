import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/screens.dart';
import 'package:mocktail/mocktail.dart';

import '../utils.dart';

void main() {
  group('HomePage', () {
    final Finder homePage = find.byType(HomePage);

    tearDown(() => mockRepositories.reset());

    testWidgets('smoke test', (WidgetTester tester) async {
      when(() => mockRepositories.items.fetch()).thenAnswer((_) async* {});

      await tester.pumpWidget(createApp(home: const HomePage()));

      await tester.pump();

      expect(homePage, findsOneWidget);
    });

    testWidgets('should show loading view on load', (WidgetTester tester) async {
      when(() => mockRepositories.items.fetch()).thenAnswer((_) async* {});

      await tester.pumpWidget(createApp(home: const HomePage()));

      await tester.pump();

      expect(find.byKey(HomePageState.loadingViewKey).descendantOf(homePage), findsOneWidget);
    });

    testWidgets('should show list of items', (WidgetTester tester) async {
      final ItemModelList expectedItems = ItemModelList.generate(3, (_) => ItemsMockImpl.generateItem());
      final Set<TagModel> uniqueTags = expectedItems.uniqueBy((ItemModel element) => element.tag);

      when(() => mockRepositories.items.fetch()).thenAnswer(
        (_) => Stream<ItemModelList>.value(expectedItems),
      );

      await tester.pumpWidget(createApp(home: const HomePage()));

      await tester.pump();
      await tester.pump();

      for (final TagModel tag in uniqueTags) {
        final ItemModel item = expectedItems.firstWhere((ItemModel element) => element.tag == tag);
        expect(find.byKey(Key(item.id)).descendantOf(homePage), findsOneWidget);
        expect(find.text(item.title), findsOneWidget);
        expect(find.text(item.tag.title), findsOneWidget);
      }
    });

    testWidgets('should show error if any', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      when(() => mockRepositories.items.fetch()).thenAnswer(
        (_) => Stream<ItemModelList>.error(expectedError),
      );

      await tester.pumpWidget(createApp(home: const HomePage()));

      await tester.pump();
      await tester.pump();

      expect(find.byKey(HomePageState.errorViewKey).descendantOf(homePage), findsOneWidget);
      expect(
        find.text(expectedError.toString()).descendantOf(find.byKey(HomePageState.errorViewKey)),
        findsOneWidget,
      );
    });
  });
}
