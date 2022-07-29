import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../../utils.dart';

void main() {
  group('TagsPage', () {
    final Finder tagsPage = find.byType(TagsPage);

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const TagsPage()));

      await tester.pump();

      expect(tagsPage, findsOneWidget);
    });

    testWidgets('should show loading view on load', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const TagsPage()));

      await tester.pump();

      expect(find.byType(LoadingView).descendantOf(tagsPage), findsOneWidget);
    });

    testWidgets('should show list of tags', (WidgetTester tester) async {
      final TagViewModelList expectedItems = TagViewModelList.generate(
        3,
        (_) => TagsMockImpl.generateTag().asViewModel,
      );

      await tester.pumpWidget(createApp(
        home: const TagsPage(),
        overrides: <Override>[
          tagsProvider.overrideWithValue(
            AsyncData<TagViewModelList>(expectedItems),
          ),
        ],
      ));

      await tester.pump();
      await tester.pump();

      for (final TagViewModel item in expectedItems) {
        expect(find.byKey(Key(item.id)).descendantOf(tagsPage), findsOneWidget);
        expect(find.text(item.title.capitalize()), findsOneWidget);
        expect(find.text(item.description), findsOneWidget);
      }
    });

    testWidgets('should show error if any', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      await tester.pumpWidget(createApp(
        home: const TagsPage(),
        overrides: <Override>[
          tagsProvider.overrideWithValue(
            AsyncError<TagViewModelList>(expectedError),
          ),
        ],
      ));

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorView).descendantOf(tagsPage), findsOneWidget);
      expect(find.text(expectedError.toString()).descendantOf(find.byType(ErrorView)), findsOneWidget);
    });
  });
}
