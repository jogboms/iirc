import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/screens.dart';
import 'package:iirc/widgets.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('OnboardingPage', () {
    final Finder onboardingPage = find.byType(OnboardingPage);

    tearDown(() => mockRepositories.reset());

    testWidgets('should auto-login w/ cold start', (WidgetTester tester) async {
      when(() => mockRepositories.auth.onAuthStateChanged).thenAnswer((_) => Stream<String>.value('1'));
      when(() => mockRepositories.auth.signIn()).thenAnswer((_) async => '1');

      await tester.pumpWidget(createApp(home: const OnboardingPage(isColdStart: true)));

      await tester.pump();

      expect(onboardingPage, findsOneWidget);
      expect(find.byType(LoadingView).descendantOf(onboardingPage), findsOneWidget);
    });

    testWidgets('should not auto-login w/o cold start', (WidgetTester tester) async {
      when(() => mockRepositories.auth.onAuthStateChanged).thenAnswer((_) => Stream<String>.value('1'));
      when(() => mockRepositories.auth.signIn()).thenAnswer((_) async => '1');

      await tester.pumpWidget(createApp(home: const OnboardingPage(isColdStart: false)));

      await tester.pump();

      expect(onboardingPage, findsOneWidget);
      expect(find.byType(LoadingView).descendantOf(onboardingPage), findsNothing);
      expect(find.byKey(OnboardingDataViewState.signInButtonKey).descendantOf(onboardingPage), findsOneWidget);
    });

    testWidgets('should navigate to MenuPage on successful login', (WidgetTester tester) async {
      when(() => mockRepositories.auth.onAuthStateChanged).thenAnswer((_) => Stream<String>.value('1'));
      when(() => mockRepositories.auth.signIn()).thenAnswer((_) async => '1');

      await tester.pumpWidget(createApp(home: const OnboardingPage(isColdStart: true)));

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
