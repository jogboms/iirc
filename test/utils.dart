import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:mocktail/mocktail.dart' as mt;

import 'mocks.dart';

class MockRepositories {
  final AuthRepository auth = MockAuthRepository();
  final UsersRepository users = MockUsersRepository();
  final ItemsRepository items = MockItemsRepository();
  final TagsRepository tags = MockTagsRepository();

  void reset() => <Object>[auth, users, items, tags].forEach(mt.reset);
}

final MockRepositories mockRepositories = MockRepositories();

Registry createRegistry({
  Environment environment = Environment.testing,
}) =>
    Registry()
      ..set<AuthRepository>(mockRepositories.auth)
      ..set<UsersRepository>(mockRepositories.users)
      ..set<ItemsRepository>(mockRepositories.items)
      ..set<TagsRepository>(mockRepositories.tags)
      ..factory((RegistryFactory di) => FetchItemsUseCase(items: di()))
      ..factory((RegistryFactory di) => FetchTagsUseCase(tags: di()))
      ..set(environment);

extension FinderExtensions on Finder {
  Finder descendantOf(Finder of) => find.descendant(of: of, matching: this);
}
