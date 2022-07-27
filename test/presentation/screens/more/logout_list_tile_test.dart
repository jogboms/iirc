import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';

import '../../../utils.dart';

void main() {
  group('LogoutListTile', () {
    tearDown(() => mockRepositories.reset());

    testWidgets('should logout', (WidgetTester tester) async {
      final StreamController<String?> controller = StreamController<String?>.broadcast();
      when(() => mockRepositories.auth.onAuthStateChanged).thenAnswer((_) => controller.stream);
      when(() => mockRepositories.auth.signOut()).thenAnswer((_) async => controller.add(null));

      await tester.pumpWidget(
        createApp(
          home: const Material(child: LogoutListTile()),
        ),
      );

      await tester.pump();

      final Finder logoutListTile = find.byType(LogoutListTile);
      expect(logoutListTile, findsOneWidget);

      await tester.tap(logoutListTile);

      verify(mockRepositories.auth.signOut).called(1);

      expect(find.byType(OnboardingPage), findsNothing);

      await tester.pump();
      await tester.pump();

      expect(find.byType(OnboardingPage), findsOneWidget);
    });
  });
}
