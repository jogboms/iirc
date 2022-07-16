// ignore_for_file: always_specify_types

import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final itemsProvider = StreamProvider<ItemModelList>((ref) {
  final Registry registry = ref.read(registryProvider);
  return registry.get<FetchItemsUseCase>().call();
});

final _filteredItemsProvider = FutureProvider<ItemModelList>((ref) async {
  final ItemModelList items = await ref.watch(itemsProvider.future);
  return items.uniqueByTag();
});

final filteredItemsStateProvider =
    StateNotifierProvider.autoDispose<PreserveStateNotifier<ItemModelList>, AsyncValue<ItemModelList>>(
  (ref) => PreserveStateNotifier(_filteredItemsProvider, ref),
);

extension UniqueByTagExtension<E extends ItemModel> on Iterable<E> {
  List<E> uniqueByTag() => fold(
        <String, E>{},
        (Map<String, E> previousValue, E element) => previousValue..putIfAbsent(element.tag.id, () => element),
      ).values.toList(growable: false);
}
