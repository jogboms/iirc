import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../../utils.dart';

void main() {
  group('MenuPage', () {
    final Finder menuPage = find.byType(MenuPage);

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(
        home: const MenuPage(),
        overrides: <Override>[
          itemsProvider.overrideWithValue(
            AsyncData<ItemViewModelList>(ItemViewModelList.empty()),
          ),
        ],
      ));

      await tester.pump();

      expect(menuPage, findsOneWidget);
      expect(find.byType(HomePage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(TagsPage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(CalendarPage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(InsightsPage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(MorePage).descendantOf(menuPage), findsOneWidget);
    });
  });
}
