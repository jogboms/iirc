import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';

import '../../../utils.dart';

// TODO: improve tests w/ input form
void main() {
  group('UpdateTagPage', () {
    final Finder updateTagPage = find.byType(UpdateTagPage);

    testWidgets('smoke test', (WidgetTester tester) async {
      final TagModel dummyTag = TagsMockImpl.generateTag();
      await tester.pumpWidget(createApp(home: UpdateTagPage(tag: dummyTag)));

      await tester.pump();

      expect(updateTagPage, findsOneWidget);
    });
  });
}
