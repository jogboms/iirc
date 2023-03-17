// ignore_for_file: always_specify_types

import 'package:equatable/equatable.dart';
import 'package:riverpod/riverpod.dart';

import '../../../models.dart';
import '../../../state.dart';

final selectedTagProvider = FutureProvider.autoDispose.family<SelectedTagState, String>((ref, id) async {
  final TagViewModelList tags = await ref.watch(tagsProvider.future);
  final ItemViewModelList items = await ref.watch(itemsProvider.future);

  return SelectedTagState(
    tag: tags.firstWhere((TagViewModel element) => element.id == id),
    items: items.where((ItemViewModel element) => element.tag.id == id).toList(),
  );
});

class SelectedTagState with EquatableMixin {
  const SelectedTagState({required this.tag, required this.items});

  final TagViewModel tag;
  final ItemViewModelList items;

  @override
  List<Object> get props => <Object>[tag, items];
}
