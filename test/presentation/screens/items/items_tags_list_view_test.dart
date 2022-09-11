import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';
import '../../../utils.dart';

void main() {
  group('ItemsTagsListView', () {
    final NavigatorObserver navigatorObserver = MockNavigatorObserver();

    setUpAll(() {
      registerFallbackValue(FakeRoute());
    });

    testWidgets('should show empty widget when empty', (WidgetTester tester) async {
      await tester.pumpWidget(
        createApp(
          home: ItemsTagsListView(
            tags: TagViewModelList.empty(),
            analytics: const NoopAnalytics(),
          ),
        ),
      );

      await tester.pump();

      expect(find.byKey(ItemsTagsListView.emptyTagsKey), findsOneWidget);
      expect(find.byKey(ItemsTagsListView.createTagButtonKey), findsOneWidget);
    });

    testWidgets('should show list of tags', (WidgetTester tester) async {
      final TagViewModelList expectedTags = TagViewModelList.generate(
        3,
        (_) => TagsMockImpl.generateTag().asViewModel,
      );

      await tester.pumpWidget(
        createApp(
          home: ItemsTagsListView(
            tags: expectedTags,
            analytics: const NoopAnalytics(),
          ),
        ),
      );

      await tester.pump();

      final Finder listView = find.byKey(ItemsTagsListView.tagsListKey);
      expect(listView, findsOneWidget);
      expect(find.byKey(ItemsTagsListView.createTagButtonKey), findsOneWidget);
      for (final TagViewModel tag in expectedTags) {
        expect(find.byKey(Key(tag.id)).descendantOf(listView), findsOneWidget);
      }
    });

    testWidgets('should navigate to tag detail screen on tag tap', (WidgetTester tester) async {
      final TagViewModel tag = TagsMockImpl.generateTag().asViewModel;

      await tester.pumpWidget(
        createApp(
          home: ItemsTagsListView(
            tags: <TagViewModel>[tag],
            analytics: const NoopAnalytics(),
          ),
          observers: <NavigatorObserver>[navigatorObserver],
        ),
      );

      await tester.pump();

      await tester.tap(find.byKey(Key(tag.id)));

      await tester.verifyPushNavigation<TagDetailPage>(navigatorObserver);
    });

    testWidgets('should navigate to create tag screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        createApp(
          home: ItemsTagsListView(
            tags: TagViewModelList.empty(),
            analytics: const NoopAnalytics(),
          ),
          observers: <NavigatorObserver>[navigatorObserver],
        ),
      );

      await tester.pump();

      await tester.tap(find.byKey(ItemsTagsListView.createTagButtonKey));

      await tester.verifyPushNavigation<CreateTagPage>(navigatorObserver);
    });
  });
}
