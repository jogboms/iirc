import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/app.dart';
import 'package:iirc/screens.dart';
import 'package:mocktail/mocktail.dart';

import '../utils.dart';

void main() {
  group('MenuPage', () {
    final Finder menuPage = find.byType(MenuPage);

    tearDown(() => mockRepositories.reset());

    testWidgets('smoke test', (WidgetTester tester) async {
      when(() => mockRepositories.items.fetch()).thenAnswer((_) async* {});
      when(() => mockRepositories.tags.fetch()).thenAnswer((_) async* {});

      await tester.pumpWidget(App(registry: createRegistry(), home: const MenuPage()));

      await tester.pump();

      expect(menuPage, findsOneWidget);
      expect(find.byType(AppBar).descendantOf(menuPage), findsOneWidget);
      expect(find.text('IIRC').descendantOf(find.byType(AppBar)), findsOneWidget);
    });
  });
}
