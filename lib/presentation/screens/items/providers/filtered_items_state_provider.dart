// ignore_for_file: always_specify_types

import 'package:equatable/equatable.dart';
import 'package:riverpod/riverpod.dart';

import '../../../models.dart';
import '../../../state.dart';

final _filteredItemsProvider = FutureProvider.autoDispose<FilteredItemsState>((ref) async {
  final tags = await ref.watch(tagsProvider.future);
  final items = await ref.watch(itemsProvider.future);

  return FilteredItemsState(
    tags: tags,
    items: filterBySearchTagQuery(
      ref,
      elements: items.uniqueByTag(),
      byTitle: (element) => element.tag.title,
      byDescription: (element) => element.tag.description,
    ),
  );
});

final filteredItemsStateProvider =
    StateNotifierProvider.autoDispose<PreserveStateNotifier<FilteredItemsState>, AsyncValue<FilteredItemsState>>(
  (ref) => PreserveStateNotifier(_filteredItemsProvider, ref),
);

class FilteredItemsState with EquatableMixin {
  const FilteredItemsState({required this.tags, required this.items});

  final TagViewModelList tags;
  final ItemViewModelList items;

  @override
  List<Object> get props => <Object>[tags, items];
}

extension UniqueByTagExtension<E extends ItemViewModel> on Iterable<E> {
  List<E> uniqueByTag() => fold(
        <String, E>{},
        (Map<String, E> previousValue, E element) => previousValue..putIfAbsent(element.tag.id, () => element),
      ).values.toList(growable: false);
}
