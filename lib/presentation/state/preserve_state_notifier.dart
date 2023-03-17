import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

class PreserveStateNotifier<T> extends StateNotifier<AsyncValue<T>> {
  factory PreserveStateNotifier(
    ProviderListenable<AsyncValue<T>> provider,
    AutoDisposeStateNotifierProviderRef<PreserveStateNotifier<T>, AsyncValue<T>> ref,
  ) {
    final PreserveStateNotifier<T> notifier = PreserveStateNotifier<T>._();
    ref.onDispose(ref.listen(provider, notifier._onData).close);
    return notifier;
  }

  // ignore: always_specify_types
  PreserveStateNotifier._([super.initialValue = const AsyncValue.loading()]);

  @visibleForTesting
  static PreserveStateNotifier<T> withState<T>(AsyncValue<T> value) => PreserveStateNotifier<T>._(value);

  void _onData(AsyncValue<T>? previous, AsyncValue<T> next) {
    state = (next is AsyncLoading && previous is AsyncData) ? previous! : next;
  }
}
