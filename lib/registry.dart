import 'package:flutter/widgets.dart';

typedef RegistryFactory = U Function<U>();

class Registry {
  final Expando<Object> _instances = Expando<Object>('Registry');

  void set<T>(T instance) => _instances.set<T>(instance);

  T get<T>() => _instances.getOrNull<T Function()>()?.call() ?? _instances.get<T>();

  void factory<T>(T Function(RegistryFactory) fn) => set<T Function()>(() => fn(<U>() => get<U>()));

  void override<T>(T instance) => _instances.set(instance, true);

  @visibleForTesting
  void replace<T>(T instance) => _instances.set(instance, true);
}

extension on Expando<Object> {
  void set<T>(T instance, [bool replace = false]) {
    assert(!(this[T] != null && !replace), 'Instance of type $T is already added to the Registry');
    this[T] = instance;
  }

  T? getOrNull<T>() => this[T] as T?;

  T get<T>() {
    final Object? instance = this[T];
    assert(instance != null, 'Instance of type $T was not added to the Registry');
    return instance as T;
  }
}

class RegistryProvider extends InheritedWidget {
  const RegistryProvider({super.key, required this.data, required super.child});

  final Registry data;

  static Registry of(BuildContext context) {
    final InheritedElement? result = context.getElementForInheritedWidgetOfExactType<RegistryProvider>();
    assert(result != null, 'No RegistryProvider found in context');
    return (result!.widget as RegistryProvider).data;
  }

  @override
  bool updateShouldNotify(RegistryProvider oldWidget) => oldWidget.data != data;
}

extension RegistryBuildContext on BuildContext {
  Registry get registry => RegistryProvider.of(this);
}
