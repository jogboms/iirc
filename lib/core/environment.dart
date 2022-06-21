import 'dart:io';

enum Environment {
  mock,
  dev,
  prod,
  testing;

  bool get isMock => this == Environment.mock;

  bool get isDev => this == Environment.dev;

  bool get isProduction => this == Environment.prod;

  bool get isTesting => this == Environment.testing;

  bool get isDebugging {
    bool condition = false;
    assert(() {
      condition = true;
      return condition;
    }());
    return condition;
  }
}

const String _env = String.fromEnvironment('env.mode', defaultValue: 'mock');

Environment? _environment;

Environment get environment => _environment ??= _getEnvironment();

Environment _getEnvironment() {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return Environment.testing;
  }

  final Map<String, Environment> _envs = Environment.values.asNameMap();
  if (!_envs.containsKey(_env)) {
    throw Exception("Invalid runtime environment: '$_env'. Available environments: ${_envs.keys.join(', ')}");
  }

  return _envs[_env]!;
}
