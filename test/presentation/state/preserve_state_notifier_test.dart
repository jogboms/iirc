import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../utils.dart';

Future<void> main() async {
  group('PreserveStateNotifier', () {
    final ProviderListener<AsyncValue<String>> listener = ProviderListener<AsyncValue<String>>();

    StateController<String> createProvider() {
      final StateController<String> controller = StateController<String>('');
      final StreamProvider<String> stream =
          StreamProvider<String>((StreamProviderRef<String> ref) => controller.stream);
      final FutureProvider<String> future =
          FutureProvider<String>((FutureProviderRef<String> ref) => ref.watch(stream.future));
      final AutoDisposeStateNotifierProvider<PreserveStateNotifier<String>, AsyncValue<String>> provider =
          StateNotifierProvider.autoDispose<PreserveStateNotifier<String>, AsyncValue<String>>(
        (AutoDisposeStateNotifierProviderRef<PreserveStateNotifier<String>, AsyncValue<String>> ref) =>
            PreserveStateNotifier<String>(future, ref),
      );

      final ProviderContainer container = createProviderContainer();
      container.listen<AsyncValue<String>>(provider, listener, fireImmediately: true);
      addTearDown(container.dispose);
      addTearDown(listener.reset);
      addTearDown(controller.dispose);
      return controller;
    }

    test('should retain previous state when new state is loading', () async {
      final StateController<String> controller = createProvider();

      controller.state = '1';
      controller.state = '2';
      await pumpEventQueue();

      expect(
        listener.log,
        <AsyncValue<String>>[
          const AsyncLoading<Never>(),
          const AsyncData<String>('1'),
          const AsyncData<String>('2'),
        ],
      );
    });
  });
}
