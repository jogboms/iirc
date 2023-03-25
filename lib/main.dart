import 'dart:async' as async;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl_standalone.dart' if (dart.library.html) 'package:intl/intl_browser.dart';
import 'package:sentry/sentry.dart';
import 'package:universal_io/io.dart' as io;

import 'core.dart';
import 'data.dart';
import 'domain.dart';
import 'firebase_options.dev.dart' as dev;
import 'firebase_options.prod.dart' as prod;
import 'presentation.dart';

const String _sentryDns = String.fromEnvironment('env.sentryDns');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await findSystemLocale();

  final _Repository repository;
  final ReporterClient reporterClient;
  final NavigatorObserver navigationObserver;
  final Analytics analytics;
  switch (environment) {
    case Environment.dev:
    case Environment.prod:
      final bool isDev = environment.isDev;
      final Firebase firebase = await Firebase.initialize(
        options: isDev ? dev.DefaultFirebaseOptions.currentPlatform : prod.DefaultFirebaseOptions.currentPlatform,
        isAnalyticsEnabled: !isDev,
      );
      final DeviceInformation deviceInformation = await AppDeviceInformation.initialize();
      reporterClient = _ReporterClient(
        SentryClient(SentryOptions(dsn: _sentryDns)),
        deviceInformation: deviceInformation,
        environment: environment,
      );
      repository = _Repository.firebase(firebase, isDev);
      navigationObserver = firebase.analytics.navigatorObserver;
      analytics = _Analytics(firebase.analytics);
      break;
    case Environment.testing:
    case Environment.mock:
      reporterClient = const _NoopReporterClient();
      repository = _Repository.mock();
      navigationObserver = NavigatorObserver();
      analytics = const _PrintAnalytics();
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

    /// Analytics.
    ..set(analytics)

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

  runApp(
    ProviderScope(
      overrides: <Override>[
        registryProvider.overrideWithValue(registry),
      ],
      child: ErrorBoundary(
        isReleaseMode: !environment.isDebugging,
        errorViewBuilder: (_) => const AppCrashErrorView(),
        onException: AppLog.e,
        onCrash: errorReporter.reportCrash,
        child: App(
          registry: registry,
          navigatorObservers: <NavigatorObserver>[navigationObserver],
        ),
      ),
    ),
  );
}

class _Repository {
  _Repository.firebase(Firebase firebase, bool isDev)
      : auth = AuthFirebaseImpl(firebase: firebase, isDev: isDev),
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
  const _ReporterClient(
    this.client, {
    required this.deviceInformation,
    required this.environment,
  });

  final SentryClient client;
  final DeviceInformation deviceInformation;
  final Environment environment;

  @override
  async.FutureOr<void> report({required StackTrace stackTrace, required Object error, Object? extra}) async {
    final SentryEvent event = SentryEvent(
      throwable: error,
      environment: environment.name.toUpperCase(),
      release: deviceInformation.appVersion,
      tags: deviceInformation.toMap(),
      user: SentryUser(
        id: deviceInformation.deviceId,
      ),
      extra: extra is Map ? extra as Map<String, dynamic>? : <String, dynamic>{'extra': extra},
    );

    await client.captureEvent(event, stackTrace: stackTrace);
  }

  @override
  async.FutureOr<void> reportCrash(FlutterErrorDetails details) =>
      client.captureException(details.exception, stackTrace: details.stack);

  @override
  void log(Object object) => AppLog.i(object);
}

class _NoopReporterClient implements ReporterClient {
  const _NoopReporterClient();

  @override
  async.FutureOr<void> report({required StackTrace stackTrace, required Object error, Object? extra}) {}

  @override
  async.FutureOr<void> reportCrash(FlutterErrorDetails details) {}

  @override
  void log(Object object) {}
}

class _Analytics implements Analytics {
  const _Analytics(this.analytics);

  final CloudAnalytics analytics;
  static const Analytics _log = _PrintAnalytics();

  @override
  Future<void> log(AnalyticsEvent event) async {
    if (kDebugMode) {
      return _log.log(event);
    }
    return analytics.log(event.name, event.parameters);
  }

  @override
  Future<void> setCurrentScreen(String name) async {
    if (kDebugMode) {
      return _log.setCurrentScreen(name);
    }
    return analytics.setCurrentScreen(name);
  }

  @override
  Future<void> setUserId(String id) async => analytics.setUserId(id);

  @override
  Future<void> removeUserId() async => analytics.removeUserId();
}

class _PrintAnalytics extends NoopAnalytics {
  const _PrintAnalytics();

  @override
  Future<void> log(AnalyticsEvent event) async => AppLog.i(event);

  @override
  Future<void> setCurrentScreen(String name) async => AppLog.i('screen_view: $name');
}
