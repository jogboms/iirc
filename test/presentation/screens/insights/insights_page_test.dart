import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/presentation.dart';

import '../../../utils.dart';

void main() {
  group('InsightsPage', () {
    final Finder insightsPage = find.byType(InsightsPage);

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const InsightsPage()));

      await tester.pump();

      expect(insightsPage, findsOneWidget);
    });
  });
}
