// ignore_for_file: always_specify_types

import 'package:riverpod/riverpod.dart';

import '../../../models/item_view_model.dart';
import '../../../state/items_provider.dart';
import '../../../state/preserve_state_notifier.dart';
import '../../../state/search_tag_state_provider.dart';

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
