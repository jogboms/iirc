import 'package:flutter/widgets.dart';
import 'package:iirc/core.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
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
    ..factory<FetchItemsUseCase>((RegistryFactory di) => FetchItemsUseCase(items: di()))
    ..set<Environment>(environment);

  runApp(
    App(
      registry: registry,
    ),
  );
}
