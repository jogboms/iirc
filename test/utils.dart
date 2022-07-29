import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/app.dart';
import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
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

class MockUseCases {
  final FetchItemsUseCase fetchItemsUseCase = MockFetchItemsUseCase();
  final FetchTagsUseCase fetchTagsUseCase = MockFetchTagsUseCase();
  final GetAccountUseCase getAccountUseCase = MockGetAccountUseCase();
  final CreateItemUseCase createItemUseCase = MockCreateItemUseCase();
  final CreateTagUseCase createTagUseCase = MockCreateTagUseCase();
  final UpdateUserUseCase updateUserUseCase = MockUpdateUserUseCase();
  final UpdateTagUseCase updateTagUseCase = MockUpdateTagUseCase();
  final UpdateItemUseCase updateItemUseCase = MockUpdateItemUseCase();
  final DeleteItemUseCase deleteItemUseCase = MockDeleteItemUseCase();
  final DeleteTagUseCase deleteTagUseCase = MockDeleteTagUseCase();
  final SignInUseCase signInUseCase = MockSignInUseCase();
  final SignOutUseCase signOutUseCase = MockSignOutUseCase();
  final CreateUserUseCase createUserUseCase = MockCreateUserUseCase();
  final FetchUserUseCase fetchUserUseCase = MockFetchUserUseCase();

  void reset() => <Object>[
        fetchItemsUseCase,
        fetchTagsUseCase,
        getAccountUseCase,
        createItemUseCase,
        createTagUseCase,
        updateUserUseCase,
        updateTagUseCase,
        updateItemUseCase,
        deleteItemUseCase,
        deleteTagUseCase,
        signInUseCase,
        signOutUseCase,
        createUserUseCase,
        fetchUserUseCase
      ].forEach(mt.reset);
}

final MockUseCases mockUseCases = MockUseCases();

Registry createRegistry({
  Environment environment = Environment.testing,
}) =>
    Registry()
      ..set(mockRepositories.auth)
      ..set(mockRepositories.users)
      ..set(mockRepositories.items)
      ..set(mockRepositories.tags)
      ..factory((RegistryFactory di) => FetchItemsUseCase(items: di(), tags: di()))
      ..factory((RegistryFactory di) => FetchTagsUseCase(tags: di()))
      ..factory((RegistryFactory di) => GetAccountUseCase(auth: di()))
      ..factory((RegistryFactory di) => CreateItemUseCase(items: di()))
      ..factory((RegistryFactory di) => CreateTagUseCase(tags: di()))
      ..factory((RegistryFactory di) => UpdateUserUseCase(users: di()))
      ..factory((RegistryFactory di) => UpdateTagUseCase(tags: di()))
      ..factory((RegistryFactory di) => UpdateItemUseCase(items: di()))
      ..factory((RegistryFactory di) => DeleteItemUseCase(items: di()))
      ..factory((RegistryFactory di) => DeleteTagUseCase(tags: di()))
      ..factory((RegistryFactory di) => SignInUseCase(auth: di()))
      ..factory((RegistryFactory di) => SignOutUseCase(auth: di()))
      ..factory((RegistryFactory di) => CreateUserUseCase(users: di()))
      ..factory((RegistryFactory di) => FetchUserUseCase(users: di()))
      ..set(environment);

ProviderContainer createProviderContainer({
  ProviderContainer? parent,
  Registry? registry,
  List<Override>? overrides,
  List<ProviderObserver>? observers,
}) {
  final ProviderContainer container = ProviderContainer(
    parent: parent,
    overrides: <Override>[
      registryProvider.overrideWithValue(
        registry ?? createRegistry().withMockedUseCases(),
      ),
      ...?overrides,
    ],
    observers: observers,
  );
  addTearDown(container.dispose);
  return container;
}

Widget createApp({
  Widget? home,
  Registry? registry,
  List<Override>? overrides,
}) {
  registry ??= createRegistry();

  return ProviderScope(
    overrides: <Override>[
      registryProvider.overrideWithValue(registry),
      ...?overrides,
    ],
    child: App(
      registry: registry,
      home: home,
    ),
  );
}

extension MockUseCasesExtensions on Registry {
  Registry withMockedUseCases() => this
    ..replace<FetchItemsUseCase>(mockUseCases.fetchItemsUseCase)
    ..replace<FetchTagsUseCase>(mockUseCases.fetchTagsUseCase)
    ..replace<GetAccountUseCase>(mockUseCases.getAccountUseCase)
    ..replace<CreateItemUseCase>(mockUseCases.createItemUseCase)
    ..replace<CreateTagUseCase>(mockUseCases.createTagUseCase)
    ..replace<UpdateUserUseCase>(mockUseCases.updateUserUseCase)
    ..replace<UpdateTagUseCase>(mockUseCases.updateTagUseCase)
    ..replace<UpdateItemUseCase>(mockUseCases.updateItemUseCase)
    ..replace<DeleteItemUseCase>(mockUseCases.deleteItemUseCase)
    ..replace<DeleteTagUseCase>(mockUseCases.deleteTagUseCase)
    ..replace<SignInUseCase>(mockUseCases.signInUseCase)
    ..replace<SignOutUseCase>(mockUseCases.signOutUseCase)
    ..replace<CreateUserUseCase>(mockUseCases.createUserUseCase)
    ..replace<FetchUserUseCase>(mockUseCases.fetchUserUseCase);
}

extension FinderExtensions on Finder {
  Finder descendantOf(Finder of) => find.descendant(of: of, matching: this);
}

extension UniqueByExtension<E> on Iterable<E> {
  Set<U> uniqueBy<U>(U Function(E) fn) =>
      fold(<U>{}, (Set<U> previousValue, E element) => <U>{...previousValue, fn(element)});
}

extension ItemModelListExtensions on ItemViewModelList {
  ItemModelList get asItemModelList => map((ItemViewModel e) => ItemModel(
        id: e.id,
        path: e.path,
        description: e.description,
        date: e.date,
        tag: e.tag.reference,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      )).toList(growable: false);
}

extension NormalizedItemModelListExtensions on NormalizedItemModelList {
  ItemModelList get asItemModelList => map((NormalizedItemModel e) => ItemModel(
        id: e.id,
        path: e.path,
        description: e.description,
        date: e.date,
        tag: e.tag.reference,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      )).toList(growable: false);
}
