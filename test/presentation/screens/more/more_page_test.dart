import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/presentation.dart';

import '../../../utils.dart';

void main() {
  group('MorePage', () {
    final Finder morePage = find.byType(MorePage);

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const MorePage()));

      await tester.pump();

      expect(morePage, findsOneWidget);
      expect(find.byType(LogoutListTile).descendantOf(morePage), findsOneWidget);
    });
  });
}
