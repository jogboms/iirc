import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/screens.dart';

import '../../utils.dart';

// TODO: improve tests w/ input form
void main() {
  group('UpdateItemPage', () {
    final Finder updateItemPage = find.byType(UpdateItemPage);

    testWidgets('smoke test', (WidgetTester tester) async {
      final ItemModel dummyItem = ItemsMockImpl.generateItem();
      await tester.pumpWidget(createApp(home: UpdateItemPage(item: dummyItem)));

      await tester.pump();

      expect(updateItemPage, findsOneWidget);
    });
  });
}
