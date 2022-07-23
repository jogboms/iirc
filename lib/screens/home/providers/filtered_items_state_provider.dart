// ignore_for_file: always_specify_types

import 'package:iirc/data.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final _filteredItemsProvider = FutureProvider.autoDispose<ItemViewModelList>(
  (ref) async => filterBySearchTagQuery(
    ref,
    elements: (await ref.watch(itemsProvider.future)).uniqueByTag(),
    byTag: (element) => element.tag,
  ),
);

final filteredItemsStateProvider =
    StateNotifierProvider.autoDispose<PreserveStateNotifier<ItemViewModelList>, AsyncValue<ItemViewModelList>>(
  (ref) => PreserveStateNotifier(_filteredItemsProvider, ref),
);

extension UniqueByTagExtension<E extends ItemViewModel> on Iterable<E> {
  List<E> uniqueByTag() => fold(
        <String, E>{},
        (Map<String, E> previousValue, E element) => previousValue..putIfAbsent(element.tag.id, () => element),
      ).values.toList(growable: false);
}
