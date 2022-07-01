import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/app.dart';
import 'package:iirc/screens.dart';
import 'package:mocktail/mocktail.dart';

import 'utils.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    when(() => mockRepositories.items.fetch()).thenAnswer((_) async* {});

    addTearDown(() => mockRepositories.reset());

    await tester.pumpWidget(
      App(
        registry: createRegistry(),
      ),
    );

    await tester.pump();

    expect(find.byKey(const Key('TESTING')), findsOneWidget);
    expect(find.text('IIRC'), findsOneWidget);
    expect(find.byType(HomePage), findsOneWidget);
  });
}
