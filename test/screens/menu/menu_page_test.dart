import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/screens.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('MenuPage', () {
    final Finder menuPage = find.byType(MenuPage);

    tearDown(() => mockRepositories.reset());

    testWidgets('smoke test', (WidgetTester tester) async {
      when(() => mockRepositories.items.fetch()).thenAnswer((_) async* {});
      when(() => mockRepositories.tags.fetch()).thenAnswer((_) async* {});

      await tester.pumpWidget(createApp(home: const MenuPage()));

      await tester.pump();

      expect(menuPage, findsOneWidget);
      expect(find.byType(HomePage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(TagsPage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(CalendarPage).descendantOf(menuPage), findsOneWidget);
      expect(find.byType(MorePage).descendantOf(menuPage), findsOneWidget);
    });
  });
}
