import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';

import '../../../utils.dart';

void main() {
  group('LogoutListTile', () {
    tearDown(mockUseCases.reset);

    testWidgets('should logout', (WidgetTester tester) async {
      when(mockUseCases.signOutUseCase.call).thenAnswer((_) async {});

      await tester.pumpWidget(
        createApp(
          registry: createRegistry().withMockedUseCases(),
          home: const Material(child: LogoutListTile()),
        ),
      );

      await tester.pump();

      final Finder logoutListTile = find.byType(LogoutListTile);
      expect(logoutListTile, findsOneWidget);

      await tester.tap(logoutListTile);

      verify(mockUseCases.signOutUseCase).called(1);

      expect(find.byType(OnboardingPage), findsNothing);

      await tester.pump();
      await tester.pump();

      expect(find.byType(OnboardingPage), findsOneWidget);
    });
  });
}
