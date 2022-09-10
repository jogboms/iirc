import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../../mocks.dart';
import '../../../utils.dart';

void main() {
  group('OnboardingPage', () {
    final Finder onboardingPage = find.byType(OnboardingPage);
    final NavigatorObserver navigatorObserver = MockNavigatorObserver();

    setUpAll(() {
      registerFallbackValue(FakeRoute());
      registerFallbackValue(FakeUpdateUserData());
    });

    tearDown(() {
      reset(navigatorObserver);
      mockUseCases.reset();
    });

    testWidgets('should auto-login w/ cold start', (WidgetTester tester) async {
      final MockAuthStateNotifier mockAuthStateNotifier = MockAuthStateNotifier();

      await tester.pumpWidget(
        createApp(
          home: const OnboardingPage(isColdStart: true),
          overrides: <Override>[
            authStateProvider.overrideWithValue(mockAuthStateNotifier..setState(AuthState.loading)),
          ],
        ),
      );

      await tester.pump();

      expect(onboardingPage, findsOneWidget);
      expect(find.byType(LoadingView).descendantOf(onboardingPage), findsOneWidget);
      verify(mockAuthStateNotifier.signIn).called(1);
    });

    testWidgets('should not auto-login w/o cold start', (WidgetTester tester) async {
      final MockAuthStateNotifier mockAuthStateNotifier = MockAuthStateNotifier();

      await tester.pumpWidget(
        createApp(
          home: const OnboardingPage(isColdStart: false),
          overrides: <Override>[
            authStateProvider.overrideWithValue(mockAuthStateNotifier),
          ],
        ),
      );

      await tester.pump();

      expect(onboardingPage, findsOneWidget);
      expect(find.byType(LoadingView).descendantOf(onboardingPage), findsNothing);
      expect(find.byKey(OnboardingDataViewState.signInButtonKey).descendantOf(onboardingPage), findsOneWidget);
      verifyZeroInteractions(mockAuthStateNotifier);
    });

    testWidgets('should navigate to MenuPage on successful login', (WidgetTester tester) async {
      final MockAuthStateNotifier mockAuthStateNotifier = MockAuthStateNotifier();

      await tester.pumpWidget(
        createApp(
          home: const OnboardingPage(isColdStart: true),
          observers: <NavigatorObserver>[navigatorObserver],
          overrides: <Override>[
            authStateProvider.overrideWithValue(mockAuthStateNotifier..setState(AuthState.loading)),
          ],
        ),
      );

      await tester.pump();

      expect(onboardingPage, findsOneWidget);
      expect(find.byType(LoadingView).descendantOf(onboardingPage), findsOneWidget);

      mockAuthStateNotifier.setState(AuthState.complete);

      await tester.verifyPushNavigation<MenuPage>(navigatorObserver);
    });

    testWidgets('should login and navigate w/ button', (WidgetTester tester) async {
      final MockAuthStateNotifier mockAuthStateNotifier = MockAuthStateNotifier();

      await tester.pumpWidget(
        createApp(
          home: const OnboardingPage(isColdStart: false),
          observers: <NavigatorObserver>[navigatorObserver],
          overrides: <Override>[
            authStateProvider.overrideWithValue(mockAuthStateNotifier),
          ],
        ),
      );

      await tester.pump();

      await tester.tap(find.byKey(OnboardingDataViewState.signInButtonKey));

      expect(onboardingPage, findsOneWidget);
      expect(find.byType(LoadingView).descendantOf(onboardingPage), findsNothing);

      mockAuthStateNotifier.setState(AuthState.complete);

      await tester.verifyPushNavigation<MenuPage>(navigatorObserver);
    });

    group('Exceptions', () {
      testWidgets('should ignore error message on popup error', (WidgetTester tester) async {
        final MockAuthStateNotifier mockAuthStateNotifier = MockAuthStateNotifier();

        await tester.pumpWidget(
          createApp(
            home: const OnboardingPage(isColdStart: false),
            overrides: <Override>[
              authStateProvider.overrideWithValue(mockAuthStateNotifier),
            ],
          ),
        );

        await tester.pump();

        mockAuthStateNotifier.setState(AuthState.reason(AuthErrorStateReason.popupBlockedByBrowser));

        await tester.pump();

        expect(onboardingPage, findsOneWidget);
        expect(find.byKey(AppSnackBar.errorKey), findsNothing);
      });

      testWidgets('should show error messages on failed error', (WidgetTester tester) async {
        final MockAuthStateNotifier mockAuthStateNotifier = MockAuthStateNotifier();

        await tester.pumpWidget(
          createApp(
            home: const OnboardingPage(isColdStart: false),
            overrides: <Override>[
              authStateProvider.overrideWithValue(mockAuthStateNotifier),
            ],
          ),
        );

        await tester.pump();

        mockAuthStateNotifier.setState(AuthState.reason(AuthErrorStateReason.failed));

        await tester.pump();

        expect(onboardingPage, findsOneWidget);
        expect(find.byKey(AppSnackBar.errorKey), findsOneWidget);
      });

      testWidgets('should show error messages on error', (WidgetTester tester) async {
        final MockAuthStateNotifier mockAuthStateNotifier = MockAuthStateNotifier();

        await tester.pumpWidget(
          createApp(
            home: const OnboardingPage(isColdStart: false),
            overrides: <Override>[
              authStateProvider.overrideWithValue(mockAuthStateNotifier),
            ],
          ),
        );

        await tester.pump();

        mockAuthStateNotifier.setState(AuthState.reason(AuthErrorStateReason.failed));

        await tester.pump();

        expect(find.byKey(AppSnackBar.errorKey), findsOneWidget);

        mockAuthStateNotifier.setState(AuthState.reason(AuthErrorStateReason.networkUnavailable));

        await tester.pump();

        expect(find.byKey(AppSnackBar.errorKey), findsOneWidget);

        mockAuthStateNotifier.setState(AuthState.reason(AuthErrorStateReason.userDisabled));

        await tester.pump();

        expect(find.byKey(AppSnackBar.errorKey), findsOneWidget);

        mockAuthStateNotifier.setState(AuthState.reason(AuthErrorStateReason.tooManyRequests));

        await tester.pump();

        expect(find.byKey(AppSnackBar.errorKey), findsOneWidget);

        mockAuthStateNotifier.setState(AuthState.reason(AuthErrorStateReason.message));

        await tester.pump();

        expect(find.byKey(AppSnackBar.errorKey), findsOneWidget);
      });
    });
  });
}

class MockAuthStateNotifier extends StateNotifier<AuthState> with Mock implements AuthStateNotifier {
  MockAuthStateNotifier([super.state = AuthState.idle]);

  // ignore: use_setters_to_change_properties
  void setState(AuthState newState) => state = newState;
}
