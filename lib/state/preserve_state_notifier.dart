import 'package:riverpod/riverpod.dart';

class PreserveStateNotifier<T> extends StateNotifier<AsyncValue<T>> {
  PreserveStateNotifier(
    ProviderListenable<AsyncValue<T>> provider,
    AutoDisposeStateNotifierProviderRef<PreserveStateNotifier<T>, AsyncValue<T>> ref,
    // ignore: always_specify_types
  ) : super(const AsyncValue.loading()) {
    ref.onDispose(ref.listen(provider, _onData));
  }

  void _onData(AsyncValue<T>? previous, AsyncValue<T> next) {
    if (next is AsyncLoading && previous is AsyncData) {
      state = previous!;
    } else {
      state = next;
    }
  }
}
