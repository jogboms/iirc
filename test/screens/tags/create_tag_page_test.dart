import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/screens.dart';

import '../../utils.dart';

// TODO: improve tests w/ input form
void main() {
  group('CreateTagPage', () {
    final Finder createTagPage = find.byType(CreateTagPage);

    testWidgets('smoke test', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const CreateTagPage()));

      await tester.pump();

      expect(createTagPage, findsOneWidget);
    });
  });
}
