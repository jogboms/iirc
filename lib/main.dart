import 'dart:async' as async;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl_standalone.dart' if (dart.library.html) 'package:intl/intl_browser.dart';
import 'package:universal_io/io.dart' as io;

import 'app.dart';
import 'core.dart';
import 'data.dart';
import 'domain.dart';
import 'firebase_options.dev.dart' as dev;
import 'firebase_options.prod.dart' as prod;
import 'presentation.dart';
import 'registry.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await findSystemLocale();

  final _Repository repository;
  final ReporterClient reporterClient;
  switch (environment) {
    case Environment.dev:
    case Environment.prod:
      final bool isDev = environment.isDev;
      final Firebase firebase = await Firebase.initialize(
        options: isDev ? dev.DefaultFirebaseOptions.currentPlatform : prod.DefaultFirebaseOptions.currentPlatform,
        isAnalyticsEnabled: !isDev,
      );
      reporterClient = _ReporterClient(firebase.crashlytics);
      repository = _Repository.firebase(firebase, isDev);
      break;
    case Environment.mock:
    default:
      reporterClient = const NoopReporterClient();
      repository = _Repository.mock();
      break;
  }

  final ErrorReporter errorReporter = ErrorReporter(client: reporterClient);
  AppLog.init(
    logFilter: () => kDebugMode && !environment.isTesting,
    exceptionFilter: (Object error) {
      const List<Type> ignoreTypes = <Type>[
        io.SocketException,
        io.HandshakeException,
        async.TimeoutException,
      ];
      return !kDebugMode && !ignoreTypes.contains(error.runtimeType);
    },
    onException: errorReporter.report,
    onLog: (Object? message) => debugPrint(message?.toString()),
  );

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
    ..factory((RegistryFactory di) => UpdateUserUseCase(users: di()))
    ..factory((RegistryFactory di) => UpdateTagUseCase(tags: di()))
    ..factory((RegistryFactory di) => UpdateItemUseCase(items: di()))
    ..factory((RegistryFactory di) => DeleteItemUseCase(items: di()))
    ..factory((RegistryFactory di) => DeleteTagUseCase(tags: di()))
    ..factory((RegistryFactory di) => SignInUseCase(auth: di()))
    ..factory((RegistryFactory di) => SignOutUseCase(auth: di()))
    ..factory((RegistryFactory di) => CreateUserUseCase(users: di()))
    ..factory((RegistryFactory di) => FetchUserUseCase(users: di()))

    /// Environment.
    ..set(environment);

  ErrorBoundary.runApp(
    ProviderScope(
      overrides: <Override>[
        registryProvider.overrideWithValue(registry),
      ],
      child: App(
        registry: registry,
      ),
    ),
    isReleaseMode: !environment.isDebugging,
    errorViewBuilder: (_) => const AppCrashErrorView(),
    onException: AppLog.e,
  );
}

class _Repository {
  _Repository.firebase(Firebase firebase, bool isDev)
      : auth = AuthFirebaseImpl(firebase: firebase),
        items = ItemsFirebaseImpl(firebase: firebase, isDev: isDev),
        tags = TagsFirebaseImpl(firebase: firebase, isDev: isDev),
        users = UsersFirebaseImpl(firebase: firebase);

  _Repository.mock()
      : auth = AuthMockImpl(),
        items = ItemsMockImpl(),
        tags = TagsMockImpl(),
        users = UsersMockImpl();

  final AuthRepository auth;
  final ItemsRepository items;
  final TagsRepository tags;
  final UsersRepository users;
}

class _ReporterClient implements ReporterClient {
  const _ReporterClient(this.client);

  final Crashlytics client;

  @override
  async.FutureOr<void> report({required StackTrace stackTrace, required Object error, Object? extra}) async =>
      client.report(error, stackTrace);

  @override
  void log(Object object) => AppLog.i(object);
}
