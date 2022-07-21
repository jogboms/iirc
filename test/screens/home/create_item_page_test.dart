import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/screens.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

// TODO: improve tests w/ input form
void main() {
  group('CreateItemPage', () {
    final Finder createItemPage = find.byType(CreateItemPage);

    tearDown(() => mockRepositories.reset());

    testWidgets('smoke test', (WidgetTester tester) async {
      when(() => mockRepositories.tags.fetch()).thenAnswer((_) async* {});
      when(() => mockRepositories.items.fetch()).thenAnswer((_) async* {});

      await tester.pumpWidget(createApp(home: const CreateItemPage(asModal: false)));

      await tester.pump();

      expect(createItemPage, findsOneWidget);
    });
  });
}
