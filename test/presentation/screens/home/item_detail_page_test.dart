import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../../utils.dart';

void main() {
  group('ItemDetailPage', () {
    final Finder itemDetailPage = find.byType(ItemDetailPage);

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const ItemDetailPage(id: '1')));

      await tester.pump();

      expect(itemDetailPage, findsOneWidget);
    });

    testWidgets('should show loading view on load', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const ItemDetailPage(id: '1')));

      await tester.pump();

      expect(find.byType(LoadingView).descendantOf(itemDetailPage), findsOneWidget);
    });

    testWidgets('should show details of item', (WidgetTester tester) async {
      final TagModel tag = TagsMockImpl.generateTag();
      final NormalizedItemModel item = ItemsMockImpl.generateNormalizedItem(tag: tag);

      await tester.pumpWidget(createApp(
        home: ItemDetailPage(id: item.id),
        overrides: <Override>[
          selectedItemStateProvider(item.id).overrideWithValue(
            PreserveStateNotifier.withState<ItemViewModel>(
              AsyncData<ItemViewModel>(ItemViewModel.fromItem(item)),
            ),
          ),
        ],
      ));

      await tester.pump();
      await tester.pump();

      expect(find.text(item.description), findsOneWidget);
    });

    testWidgets('should show error if item fetch fails', (WidgetTester tester) async {
      final Exception expectedError = Exception('an error');

      await tester.pumpWidget(createApp(
        home: const ItemDetailPage(id: '1'),
        overrides: <Override>[
          selectedItemStateProvider('1').overrideWithValue(
            PreserveStateNotifier.withState<ItemViewModel>(
              AsyncError<ItemViewModel>(expectedError),
            ),
          ),
        ],
      ));

      await tester.pump();
      await tester.pump();

      expect(find.byType(ErrorView).descendantOf(itemDetailPage), findsOneWidget);
      expect(find.text(expectedError.toString()).descendantOf(find.byType(ErrorView)), findsOneWidget);
    });
  });
}
