import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';
import 'utils.dart';

void main() {
  final AccountModel dummyAccount = AuthMockImpl.generateAccount();
  final UserModel dummyUser = UsersMockImpl.user;

  setUpAll(() {
    registerFallbackValue(dummyAccount);
    registerFallbackValue(FakeUpdateUserData());
  });

  testWidgets('Smoke test', (WidgetTester tester) async {
    final Finder onboardingPage = find.byType(OnboardingPage);
    final Finder menuPage = find.byType(MenuPage);

    when(() => mockUseCases.fetchUserUseCase.call(any())).thenAnswer((_) async => dummyUser);
    when(() => mockUseCases.signInUseCase.call()).thenAnswer((_) async => dummyAccount);
    when(() => mockUseCases.updateUserUseCase.call(any())).thenAnswer((_) async => true);

    addTearDown(() => mockUseCases.reset());

    await tester.pumpWidget(
      createApp(
        registry: createRegistry().withMockedUseCases(),
        includeMaterial: false,
      ),
    );

    await tester.pump();

    expect(onboardingPage, findsOneWidget);
    expect(find.byType(LoadingView).descendantOf(onboardingPage), findsOneWidget);
    expect(menuPage, findsNothing);

    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('TESTING')), findsOneWidget);
    expect(menuPage, findsOneWidget);
    expect(find.byType(HomePage).descendantOf(menuPage), findsOneWidget);
    expect(find.byType(CalendarPage).descendantOf(menuPage), findsOneWidget);
    expect(find.byType(InsightsPage).descendantOf(menuPage), findsOneWidget);
    expect(find.byType(MorePage).descendantOf(menuPage), findsOneWidget);
  });
}
