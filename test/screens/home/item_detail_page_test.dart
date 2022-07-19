import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/screens.dart';

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
  });
}
