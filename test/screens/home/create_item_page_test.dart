import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/screens.dart';

import '../../utils.dart';

// TODO: improve tests w/ input form
void main() {
  group('CreateItemPage', () {
    final Finder createItemPage = find.byType(CreateItemPage);

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const CreateItemPage()));

      await tester.pump();

      expect(createItemPage, findsOneWidget);
    });
  });
}
