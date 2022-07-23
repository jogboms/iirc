import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/screens.dart';
import 'package:iirc/widgets.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('HomePage', () {
    final Finder homePage = find.byType(HomePage);

    setUp(() {
      when(() => mockRepositories.auth.onAuthStateChanged).thenAnswer((_) => Stream<String>.value('1'));
      when(() => mockRepositories.auth.account).thenAnswer((_) async => AuthMockImpl.generateAccount());
      when(() => mockRepositories.users.fetch(any())).thenAnswer((_) async => UsersMockImpl.user);
    });

    tearDown(() => mockRepositories.reset());

    testWidgets('smoke test', (WidgetTester tester) async {
      when(() => mockRepositories.items.fetch(any())).thenAnswer((_) async* {});

      await tester.pumpWidget(createApp(home: const HomePage()));

      await tester.pump();

      expect(homePage, findsOneWidget);
    });

    testWidgets('should show loading view on load', (WidgetTester tester) async {
      when(() => mockRepositories.items.fetch(any())).thenAnswer((_) async* {});

      await tester.pumpWidget(createApp(home: const HomePage()));

      await tester.pump();

      expect(find.byType(LoadingView).descendantOf(homePage), findsOneWidget);
    });

    testWidgets('should show unique list of items', (WidgetTester tester) async {
      final TagModel tag = TagsMockImpl.generateTag();
      final ItemViewModelList expectedItems = ItemViewModelList.generate(
        3,
        (_) => ItemViewModel.fromItem(ItemsMockImpl.generateItem(tag: tag), tag),
      );
      final Set<TagModel> uniqueTags = expectedItems.uniqueBy((ItemViewModel element) => element.tag);

      when(() => mockRepositories.items.fetch(any())).thenAnswer(
        (_) => Stream<ItemModelList>.value(expectedItems.asItemModelList),
      );
      when(() => mockRepositories.tags.fetch(any())).thenAnswer(
        (_) => Stream<TagModelList>.value(<TagModel>[tag]),
      );

      await tester.pumpWidget(createApp(home: const HomePage()));

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

      when(() => mockRepositories.items.fetch(any())).thenAnswer(
        (_) => Stream<ItemModelList>.error(expectedError),
      );
      when(() => mockRepositories.tags.fetch(any())).thenAnswer(
        (_) => Stream<TagModelList>.value(<TagModel>[]),
      );

      await tester.pumpWidget(createApp(home: const HomePage()));

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorView).descendantOf(homePage), findsOneWidget);
      expect(find.text(expectedError.toString()).descendantOf(find.byType(ErrorView)), findsOneWidget);
    });
  });
}
