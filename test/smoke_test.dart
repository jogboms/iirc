import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/screens.dart';
import 'package:iirc/widgets.dart';
import 'package:mocktail/mocktail.dart';

import 'utils.dart';

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    final Finder onboardingPage = find.byType(OnboardingPage);
    final Finder menuPage = find.byType(MenuPage);

    when(() => mockRepositories.auth.onAuthStateChanged).thenAnswer((_) => Stream<String>.value('1'));
    when(() => mockRepositories.auth.signIn()).thenAnswer((_) async => '1');
    when(() => mockRepositories.items.fetch()).thenAnswer((_) async* {});
    when(() => mockRepositories.tags.fetch()).thenAnswer((_) async* {});

    addTearDown(() => mockRepositories.reset());

    await tester.pumpWidget(createApp());

    await tester.pump();

    expect(onboardingPage, findsOneWidget);
    expect(find.byType(LoadingView).descendantOf(onboardingPage), findsOneWidget);
    expect(menuPage, findsNothing);

    await tester.pump();
    await tester.pump();

    expect(find.byKey(const Key('TESTING')), findsOneWidget);
    expect(menuPage, findsOneWidget);
    expect(find.byType(HomePage).descendantOf(menuPage), findsOneWidget);
    expect(find.byType(TagsPage).descendantOf(menuPage), findsOneWidget);
    expect(find.byType(CalendarPage).descendantOf(menuPage), findsOneWidget);
    expect(find.byType(MorePage).descendantOf(menuPage), findsOneWidget);
  });
}
