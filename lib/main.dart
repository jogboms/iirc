import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:iirc/state.dart';
import 'package:intl/intl_standalone.dart';

import 'app.dart';
import 'firebase_options.dev.dart' as dev;
import 'firebase_options.prod.dart' as prod;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await findSystemLocale();

  final _Repository repository =
      environment.isMock ? _Repository.mock() : await _Repository.firebase(environment.isDev);

  final Registry registry = Registry()

    /// Repositories.
    /// Do not use directly within the app.
    /// Added to Registry only for convenience with the UseCase factories.
    ..set(repository.auth)
    ..set(repository.users)
    ..set(repository.items)
    ..set(repository.tags)

    /// UseCases.
    /// Callable classes that may contain logic or else route directly to repositories.
    ..factory((RegistryFactory di) => FetchItemsUseCase(items: di(), tags: di()))
    ..factory((RegistryFactory di) => FetchTagsUseCase(tags: di()))
    ..factory((RegistryFactory di) => GetAccountUseCase(auth: di()))
    ..factory((RegistryFactory di) => CreateItemUseCase(items: di()))
    ..factory((RegistryFactory di) => CreateTagUseCase(tags: di()))
    ..factory((RegistryFactory di) => UpdateTagUseCase(tags: di()))
    ..factory((RegistryFactory di) => UpdateItemUseCase(items: di()))
    ..factory((RegistryFactory di) => DeleteItemUseCase(items: di()))
    ..factory((RegistryFactory di) => DeleteTagUseCase(tags: di()))
    ..factory((RegistryFactory di) => FetchAuthStateUseCase(auth: di()))
    ..factory((RegistryFactory di) => SignInUseCase(auth: di()))
    ..factory((RegistryFactory di) => SignOutUseCase(auth: di()))
    ..factory((RegistryFactory di) => CreateUserUseCase(users: di()))
    ..factory((RegistryFactory di) => FetchUserUseCase(users: di()))

    /// Environment.
    ..set(environment);

  runApp(
    ProviderScope(
      overrides: <Override>[
        registryProvider.overrideWithValue(registry),
      ],
      child: App(
        registry: registry,
      ),
    ),
  );
}

class _Repository {
  const _Repository._({required this.auth, required this.items, required this.tags, required this.users});

  static Future<_Repository> firebase(bool isDev) async {
    final Firebase instance = await Firebase.initialize(
      options: isDev ? dev.DefaultFirebaseOptions.currentPlatform : prod.DefaultFirebaseOptions.currentPlatform,
      isAnalyticsEnabled: !isDev,
    );

    return _Repository._(
      auth: AuthFirebaseImpl(firebase: instance),
      items: ItemsFirebaseImpl(firebase: instance, isDev: isDev),
      tags: TagsFirebaseImpl(firebase: instance, isDev: isDev),
      users: UsersFirebaseImpl(firebase: instance),
    );
  }

  static _Repository mock() => _Repository._(
        auth: AuthMockImpl(),
        items: ItemsMockImpl(),
        tags: TagsMockImpl(),
        users: UsersMockImpl(),
      );

  final AuthRepository auth;
  final ItemsRepository items;
  final TagsRepository tags;
  final UsersRepository users;
}
