import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models.dart';
import '../../../state.dart';

part 'selected_item_provider.g.dart';

@Riverpod(dependencies: <Object>[items])
Future<ItemViewModel> selectedItem(SelectedItemRef ref, String id) async {
  final ItemViewModelList items = await ref.watch(itemsProvider.future);

  return items.firstWhere((ItemViewModel element) => element.id == id);
}
