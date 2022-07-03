import 'package:equatable/equatable.dart';
import 'package:iirc/domain.dart';
import 'package:riverpod/riverpod.dart';

import '../../tags/providers/tags_provider.dart';
import 'items_provider.dart';

final StateProvider<String> selectedItemTagIdProvider = StateProvider<String>((StateProviderRef<String> ref) => '');

final AutoDisposeFutureProvider<SelectedItemState> selectedItemsProvider =
    FutureProvider.autoDispose((AutoDisposeFutureProviderRef<SelectedItemState> ref) async {
  final String id = ref.watch(selectedItemTagIdProvider);
  final TagModelList tags = await ref.read(tagsProvider.future);
  final ItemModelList items = await ref.read(itemsProvider.future);

  return SelectedItemState(
    tag: tags.firstWhere((TagModel element) => element.id == id),
    items: items.where((ItemModel element) => element.tag.id == id).toList(),
  );
});

class SelectedItemState with EquatableMixin {
  const SelectedItemState({required this.tag, required this.items});

  final TagModel tag;
  final ItemModelList items;

  @override
  List<Object> get props => <Object>[tag, items];
}
