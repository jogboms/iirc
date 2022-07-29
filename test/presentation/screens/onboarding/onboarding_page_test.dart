import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:iirc/registry.dart';
import 'package:mocktail/mocktail.dart';

import '../../../mocks.dart';
import '../../../utils.dart';

void main() {
  group('OnboardingPage', () {
    final Finder onboardingPage = find.byType(OnboardingPage);
    final Registry registry = createRegistry()
      ..replace<SignInUseCase>(mockUseCases.signInUseCase)
      ..replace<SignOutUseCase>(mockUseCases.signOutUseCase)
      ..replace<UpdateUserUseCase>(mockUseCases.updateUserUseCase)
      ..replace<FetchUserUseCase>(mockUseCases.fetchUserUseCase);

    setUpAll(() {
      registerFallbackValue(FakeUpdateUserData());
    });

    tearDown(() => mockUseCases.reset());

    testWidgets('should auto-login w/ cold start', (WidgetTester tester) async {
      when(() => mockUseCases.signInUseCase.call()).thenAnswer((_) async => AuthMockImpl.generateAccount());
      when(() => mockUseCases.fetchUserUseCase.call(any())).thenAnswer((_) async => UsersMockImpl.user);
      when(() => mockUseCases.updateUserUseCase.call(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(createApp(
        home: const OnboardingPage(isColdStart: true),
        registry: registry,
      ));

      await tester.pump();

      expect(onboardingPage, findsOneWidget);
      expect(find.byType(LoadingView).descendantOf(onboardingPage), findsOneWidget);
    });

    testWidgets('should logout when failure to get user', (WidgetTester tester) async {
      when(() => mockUseCases.signInUseCase.call()).thenAnswer((_) async => AuthMockImpl.generateAccount());
      when(() => mockUseCases.signOutUseCase.call()).thenAnswer((_) async {});

      await tester.pumpWidget(createApp(
        home: const OnboardingPage(isColdStart: true),
        registry: registry,
      ));

      await tester.pump();

      expect(onboardingPage, findsOneWidget);
      expect(find.byType(LoadingView).descendantOf(onboardingPage), findsOneWidget);
    });

    testWidgets('should not auto-login w/o cold start', (WidgetTester tester) async {
      await tester.pumpWidget(createApp(home: const OnboardingPage(isColdStart: false)));

      await tester.pump();

      expect(onboardingPage, findsOneWidget);
      expect(find.byType(LoadingView).descendantOf(onboardingPage), findsNothing);
      expect(find.byKey(OnboardingDataViewState.signInButtonKey).descendantOf(onboardingPage), findsOneWidget);
    });

    testWidgets('should navigate to MenuPage on successful login', (WidgetTester tester) async {
      when(() => mockUseCases.signInUseCase.call()).thenAnswer((_) async => AuthMockImpl.generateAccount());
      when(() => mockUseCases.fetchUserUseCase.call(any())).thenAnswer((_) async => UsersMockImpl.user);
      when(() => mockUseCases.updateUserUseCase.call(any())).thenAnswer((_) async => true);

      await tester.pumpWidget(createApp(
        home: const OnboardingPage(isColdStart: true),
        registry: registry,
      ));

      await tester.pump();

      expect(onboardingPage, findsOneWidget);
      expect(find.byType(LoadingView).descendantOf(onboardingPage), findsOneWidget);
      expect(find.byKey(OnboardingPageState.dataViewKey).descendantOf(onboardingPage), findsOneWidget);

      expect(find.byType(MenuPage), findsNothing);

      await tester.pump();
      await tester.pump();

      expect(find.byType(MenuPage), findsOneWidget);
    });
  });
}
