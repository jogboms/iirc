import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/screens.dart';
import 'package:iirc/widgets.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('TagDetailPage', () {
    final Finder tagDetailPage = find.byType(TagDetailPage);

    setUp(() {
      when(() => mockRepositories.auth.onAuthStateChanged).thenAnswer((_) => Stream<String>.value('1'));
      when(() => mockRepositories.auth.account).thenAnswer((_) async => AuthMockImpl.generateAccount());
      when(() => mockRepositories.users.fetch(any())).thenAnswer((_) async => UsersMockImpl.user);
    });

    tearDown(() => mockRepositories.reset());

    testWidgets('smoke test', (WidgetTester tester) async {
      when(() => mockRepositories.tags.fetch(any())).thenAnswer((_) async* {});
      when(() => mockRepositories.items.fetch(any())).thenAnswer((_) async* {});

      await tester.pumpWidget(createApp(home: const TagDetailPage(id: '1')));

      await tester.pump();

      expect(tagDetailPage, findsOneWidget);
    });

    testWidgets('should show loading view on load', (WidgetTester tester) async {
      when(() => mockRepositories.tags.fetch(any())).thenAnswer((_) async* {});
      when(() => mockRepositories.items.fetch(any())).thenAnswer((_) async* {});

      await tester.pumpWidget(createApp(home: const TagDetailPage(id: '1')));

      await tester.pump();

      expect(find.byType(LoadingView).descendantOf(tagDetailPage), findsOneWidget);
    });

    testWidgets('should show list of items for tag', (WidgetTester tester) async {
      final TagModel tag = TagsMockImpl.generateTag();
      final DateTime now = clock.now();
      final ItemModelList expectedItems = ItemModelList.generate(
        3,
        (_) => ItemsMockImpl.generateItem(tag: tag, date: now),
      );

      when(() => mockRepositories.tags.fetch(any())).thenAnswer((_) => Stream<TagModelList>.value(<TagModel>[tag]));
      when(() => mockRepositories.items.fetch(any())).thenAnswer((_) => Stream<ItemModelList>.value(expectedItems));

      await tester.pumpWidget(createApp(home: TagDetailPage(id: tag.id)));

      await tester.pump();
      await tester.pump();

      for (final ItemModel item in expectedItems) {
        expect(find.byKey(Key(item.id)).descendantOf(tagDetailPage), findsOneWidget);
        expect(find.text(item.description), findsOneWidget);
      }
    });

    testWidgets('should show error if tags fetch fails', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      when(() => mockRepositories.tags.fetch(any())).thenAnswer((_) => Stream<TagModelList>.error(expectedError));
      when(() => mockRepositories.items.fetch(any())).thenAnswer((_) => Stream<ItemModelList>.value(<ItemModel>[]));

      await tester.pumpWidget(createApp(home: const TagDetailPage(id: '1')));

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorView).descendantOf(tagDetailPage), findsOneWidget);
      expect(find.text(expectedError.toString()).descendantOf(find.byType(ErrorView)), findsOneWidget);
    });

    testWidgets('should show error if items fetch fails', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      when(() => mockRepositories.tags.fetch(any())).thenAnswer((_) => Stream<TagModelList>.value(<TagModel>[]));
      when(() => mockRepositories.items.fetch(any())).thenAnswer((_) => Stream<ItemModelList>.error(expectedError));

      await tester.pumpWidget(createApp(home: const TagDetailPage(id: '1')));

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorView).descendantOf(tagDetailPage), findsOneWidget);
      expect(find.text(expectedError.toString()).descendantOf(find.byType(ErrorView)), findsOneWidget);
    });
  });
}
