// ignore_for_file: always_specify_types

import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final itemsProvider = StreamProvider<ItemViewModelList>((ref) {
  final Registry registry = ref.read(registryProvider);
  return registry.get<FetchItemsUseCase>().call().map((element) => element.map(ItemViewModel.fromItem).toList());
});

final _filteredItemsProvider = FutureProvider<ItemViewModelList>((ref) async {
  final ItemViewModelList items = await ref.watch(itemsProvider.future);
  return items.uniqueByTag();
});

final filteredItemsStateProvider =
    StateNotifierProvider.autoDispose<PreserveStateNotifier<ItemViewModelList>, AsyncValue<ItemViewModelList>>(
  (ref) => PreserveStateNotifier(_filteredItemsProvider, ref),
);

extension UniqueByTagExtension<E extends ItemModel> on Iterable<E> {
  List<E> uniqueByTag() => fold(
        <String, E>{},
        (Map<String, E> previousValue, E element) => previousValue..putIfAbsent(element.tag.id, () => element),
      ).values.toList(growable: false);
}
