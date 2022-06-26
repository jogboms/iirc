import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/app.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockUsersRepository extends Mock implements UsersRepository {}

class MockItemsRepository extends Mock implements ItemsRepository {}

class MockTagsRepository extends Mock implements TagsRepository {}

void main() {
  testWidgets('Smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      App(
        registry: createRegistry(),
      ),
    );

    await tester.pump();

    expect(find.byKey(const Key('TESTING')), findsOneWidget);
    expect(find.text('IIRC'), findsOneWidget);
  });
}

Registry createRegistry({
  Environment environment = Environment.testing,
}) =>
    Registry()
      ..set<AuthRepository>(MockAuthRepository())
      ..set<UsersRepository>(MockUsersRepository())
      ..set<ItemsRepository>(MockItemsRepository())
      ..set<TagsRepository>(MockTagsRepository())
      ..set(environment);
