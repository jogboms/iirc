import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';

import '../../../utils.dart';

// TODO: improve tests w/ input form
void main() {
  group('UpdateItemPage', () {
    final Finder updateItemPage = find.byType(UpdateItemPage);

    testWidgets('smoke test', (WidgetTester tester) async {
      final TagModel dummyTag = TagsMockImpl.generateTag();
      final ItemViewModel dummyItem = ItemViewModel.fromItem(ItemsMockImpl.generateNormalizedItem(tag: dummyTag));
      await tester.pumpWidget(createApp(home: UpdateItemPage(item: dummyItem)));

      await tester.pump();

      expect(updateItemPage, findsOneWidget);
    });
  });
}
