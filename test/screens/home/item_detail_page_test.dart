import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/screens.dart';
import 'package:iirc/widgets.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('ItemDetailPage', () {
    final Finder itemDetailPage = find.byType(ItemDetailPage);

    tearDown(() => mockRepositories.reset());

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const ItemDetailPage(id: '1')));

      await tester.pump();

      expect(itemDetailPage, findsOneWidget);
    });

    testWidgets('should show loading view on load', (WidgetTester tester) async {
      when(() => mockRepositories.tags.fetch(any())).thenAnswer((_) async* {});
      when(() => mockRepositories.items.fetch(any())).thenAnswer((_) async* {});

      await tester.pumpWidget(createApp(home: const ItemDetailPage(id: '1')));

      await tester.pump();

      expect(find.byType(LoadingView).descendantOf(itemDetailPage), findsOneWidget);
    });

    testWidgets('should show details of item', (WidgetTester tester) async {
      final ItemModel item = ItemsMockImpl.generateItem();

      when(() => mockRepositories.items.fetch(any())).thenAnswer((_) => Stream<ItemModelList>.value(<ItemModel>[item]));

      await tester.pumpWidget(createApp(home: ItemDetailPage(id: item.id)));

      await tester.pump();
      await tester.pump();

      expect(find.text(item.description), findsOneWidget);
    });

    testWidgets('should show error if item fetch fails', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      when(() => mockRepositories.items.fetch(any())).thenAnswer((_) => Stream<ItemModelList>.error(expectedError));

      await tester.pumpWidget(createApp(home: const ItemDetailPage(id: '1')));

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorView).descendantOf(itemDetailPage), findsOneWidget);
      expect(find.text(expectedError.toString()).descendantOf(find.byType(ErrorView)), findsOneWidget);
    });
  });
}
