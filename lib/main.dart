import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:iirc/state.dart';
import 'package:intl/intl_standalone.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await findSystemLocale();

  final Registry registry = Registry()
    ..set<AuthRepository>(AuthMockImpl())
    ..set<UsersRepository>(UsersMockImpl())
    ..set<ItemsRepository>(ItemsMockImpl())
    ..set<TagsRepository>(TagsMockImpl())
    ..factory((RegistryFactory di) => FetchItemsUseCase(items: di()))
    ..factory((RegistryFactory di) => FetchTagsUseCase(tags: di()))
    ..factory((RegistryFactory di) => GetAccountUseCase(auth: di()))
    ..factory((RegistryFactory di) => FetchUserUseCase(users: di()))
    ..factory((RegistryFactory di) => CreateItemUseCase(items: di()))
    ..factory((RegistryFactory di) => CreateTagUseCase(tags: di()))
    ..set<Environment>(environment);

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
