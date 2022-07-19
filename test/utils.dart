import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/app.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:iirc/state.dart';
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
      ..factory((RegistryFactory di) => GetAccountUseCase(auth: di()))
      ..factory((RegistryFactory di) => FetchUserUseCase(users: di()))
      ..factory((RegistryFactory di) => CreateItemUseCase(items: di()))
      ..factory((RegistryFactory di) => CreateTagUseCase(tags: di()))
      ..factory((RegistryFactory di) => UpdateTagUseCase(tags: di()))
      ..factory((RegistryFactory di) => UpdateItemUseCase(items: di()))
      ..set(environment);

Widget createApp({
  Widget? home,
  Registry? registry,
}) {
  registry ??= createRegistry();

  return ProviderScope(
    overrides: <Override>[
      registryProvider.overrideWithValue(registry),
    ],
    child: App(
      registry: registry,
      home: home,
    ),
  );
}

extension FinderExtensions on Finder {
  Finder descendantOf(Finder of) => find.descendant(of: of, matching: this);
}

extension UniqueByExtension<E> on Iterable<E> {
  Set<U> uniqueBy<U>(U Function(E) fn) =>
      fold(<U>{}, (Set<U> previousValue, E element) => <U>{...previousValue, fn(element)});
}
