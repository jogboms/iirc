import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models.dart';
import '../../../state.dart';

part 'selected_tag_provider.g.dart';

@Riverpod(dependencies: <Object>[tags, items])
Future<SelectedTagState> selectedTag(SelectedTagRef ref, String id) async {
  final TagViewModelList tags = await ref.watch(tagsProvider.future);
  final ItemViewModelList items = await ref.watch(itemsProvider.future);

  return SelectedTagState(
    tag: tags.firstWhere((TagViewModel element) => element.id == id),
    items: items.where((ItemViewModel element) => element.tag.id == id).toList(),
  );
}

class SelectedTagState with EquatableMixin {
  const SelectedTagState({required this.tag, required this.items});

  final TagViewModel tag;
  final ItemViewModelList items;

  @override
  List<Object> get props => <Object>[tag, items];
}
