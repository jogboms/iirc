import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/app.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/screens.dart';
import 'package:mocktail/mocktail.dart';

import '../utils.dart';

void main() {
  group('TagsPage', () {
    final Finder tagsPage = find.byType(TagsPage);

    tearDown(() => mockRepositories.reset());

    testWidgets('smoke test', (WidgetTester tester) async {
      when(() => mockRepositories.tags.fetch()).thenAnswer((_) async* {});

      await tester.pumpWidget(App(registry: createRegistry(), home: const TagsPage()));

      await tester.pump();

      expect(tagsPage, findsOneWidget);
      expect(find.byType(AppBar).descendantOf(tagsPage), findsOneWidget);
      expect(find.text('IIRC').descendantOf(find.byType(AppBar)), findsOneWidget);
    });

    testWidgets('should show loading view on load', (WidgetTester tester) async {
      when(() => mockRepositories.tags.fetch()).thenAnswer((_) async* {});

      await tester.pumpWidget(App(registry: createRegistry(), home: const TagsPage()));

      await tester.pump();

      expect(find.byKey(TagsPageState.loadingViewKey).descendantOf(tagsPage), findsOneWidget);
    });

    testWidgets('should show list of tags', (WidgetTester tester) async {
      final List<TagModel> expectedItems = List<TagModel>.generate(3, (_) => TagsMockImpl.generateTag());

      when(() => mockRepositories.tags.fetch()).thenAnswer(
        (_) => Stream<List<TagModel>>.value(expectedItems),
      );

      await tester.pumpWidget(App(registry: createRegistry(), home: const TagsPage()));

      await tester.pump();
      await tester.pump();

      for (final TagModel item in expectedItems) {
        expect(find.byKey(Key(item.id)).descendantOf(tagsPage), findsOneWidget);
        expect(find.text(item.title), findsOneWidget);
        expect(find.text(item.description), findsOneWidget);
      }
    });

    testWidgets('should show error if any', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      when(() => mockRepositories.tags.fetch()).thenAnswer(
        (_) => Stream<List<TagModel>>.error(expectedError),
      );

      await tester.pumpWidget(App(registry: createRegistry(), home: const TagsPage()));

      await tester.pump();
      await tester.pump();

      expect(find.byKey(TagsPageState.errorViewKey).descendantOf(tagsPage), findsOneWidget);
      expect(
        find.text(expectedError.toString()).descendantOf(find.byKey(TagsPageState.errorViewKey)),
        findsOneWidget,
      );
    });
  });
}
