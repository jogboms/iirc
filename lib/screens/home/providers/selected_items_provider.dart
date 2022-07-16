// ignore_for_file: always_specify_types

import 'package:equatable/equatable.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

import '../../tags/providers/tags_provider.dart';
import 'items_provider.dart';

final _selectedItemsProvider = FutureProvider.autoDispose.family<SelectedItemState, String>((ref, id) async {
  final TagModelList tags = await ref.watch(tagsStateProvider.future);
  final ItemModelList items = await ref.watch(itemsProvider.future);

  return SelectedItemState(
    tag: tags.firstWhere((TagModel element) => element.id == id),
    items: items.where((ItemModel element) => element.tag.id == id).toList(),
  );
});

final selectedItemsStateProvider = StateNotifierProvider.autoDispose
    .family<PreserveStateNotifier<SelectedItemState>, AsyncValue<SelectedItemState>, String>(
  (ref, id) => PreserveStateNotifier(_selectedItemsProvider(id), ref),
);

class SelectedItemState with EquatableMixin {
  const SelectedItemState({required this.tag, required this.items});

  final TagModel tag;
  final ItemModelList items;

  @override
  List<Object> get props => <Object>[tag, items];
}
