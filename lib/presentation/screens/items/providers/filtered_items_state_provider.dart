import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models.dart';
import '../../../state.dart';

part 'filtered_items_state_provider.g.dart';

@Riverpod(dependencies: <Object>[tags, items])
Future<FilteredItemsState> filteredItems(FilteredItemsRef ref) async {
  final List<TagViewModel> tags = await ref.watch(tagsProvider.future);
  final List<ItemViewModel> items = await ref.watch(itemsProvider.future);

  return FilteredItemsState(
    tags: tags,
    items: filterBySearchTagQuery(
      ref,
      elements: items.uniqueByTag(),
      byTitle: (ItemViewModel element) => element.tag.title,
      byDescription: (ItemViewModel element) => element.tag.description,
    ),
  );
}

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
