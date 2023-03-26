import 'package:meta/meta.dart';

typedef RegistryFactory = U Function<U>();

class Registry {
  final Expando<Object> _instances = Expando<Object>('Registry');

  void set<T>(T instance) => _instances.set<T>(instance);

  T get<T>() {
    final Object instance = _instances.get<T>();
    if (instance is _LazyFactory<T>) {
      final T lazyInstance = instance._factory.call();
      replace(lazyInstance);
      return lazyInstance;
    }
    if (instance is _Factory<T>) {
      return instance.call();
    }
    return instance as T;
  }

  void factory<T>(T Function(RegistryFactory) fn, {@visibleForTesting bool lazy = false}) =>
      _instances.set<T>(() => fn(<U>() => get<U>()), lazy: lazy);

  void lazy<T>(T Function(RegistryFactory) fn) => factory(fn, lazy: true);

  @visibleForTesting
  void replace<T>(T instance) => _instances.set<T>(instance, replace: true);
}

extension on Expando<Object> {
  void set<T>(Object? instance, {bool lazy = false, bool replace = false}) {
    assert(!(this[T] != null && !replace), 'Instance of type $T is already added to the Registry');
    this[T] = lazy && instance is _Factory<T> ? _LazyFactory<T>(instance) : instance;
  }

  Object get<T>() {
    final Object? instance = this[T];
    if (instance == null) {
      throw ArgumentError('Instance of type $T was not added to the Registry');
    }
    return instance;
  }
}

typedef _Factory<T> = T Function();

class _LazyFactory<T> {
  const _LazyFactory(this._factory);

  final _Factory<T> _factory;
}
