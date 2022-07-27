import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../../utils.dart';

void main() {
  group('HomePage', () {
    final Finder homePage = find.byType(HomePage);

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const HomePage()));

      await tester.pump();

      expect(homePage, findsOneWidget);
    });

    testWidgets('should show loading view on load', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const HomePage()));

      await tester.pump();

      expect(find.byType(LoadingView).descendantOf(homePage), findsOneWidget);
    });

    testWidgets('should show unique list of items', (WidgetTester tester) async {
      final TagModel tag = TagsMockImpl.generateTag();
      final ItemViewModelList expectedItems = ItemViewModelList.generate(
        3,
        (_) => ItemViewModel.fromItem(ItemsMockImpl.generateNormalizedItem(tag: tag)),
      );
      final Set<TagModel> uniqueTags = expectedItems.uniqueBy((ItemViewModel element) => element.tag);

      await tester.pumpWidget(createApp(
        home: const HomePage(),
        overrides: <Override>[
          itemsProvider.overrideWithValue(
            AsyncData<ItemViewModelList>(expectedItems),
          ),
        ],
      ));

      await tester.pump();
      await tester.pump();

      for (final TagModel tag in uniqueTags) {
        final ItemViewModel item = expectedItems.firstWhere((ItemViewModel element) => element.tag.id == tag.id);
        expect(find.byKey(Key(item.id)).descendantOf(homePage), findsOneWidget);
        expect(find.text(item.description), findsOneWidget);
        expect(find.text(item.tag.title.capitalize()), findsOneWidget);
      }
    });

    testWidgets('should show error if any', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      await tester.pumpWidget(createApp(
        home: const HomePage(),
        overrides: <Override>[
          itemsProvider.overrideWithValue(
            AsyncError<ItemViewModelList>(expectedError),
          ),
        ],
      ));

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorView).descendantOf(homePage), findsOneWidget);
      expect(find.text(expectedError.toString()).descendantOf(find.byType(ErrorView)), findsOneWidget);
    });
  });
}
