// ignore_for_file: always_specify_types

import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final _selectedItemProvider = FutureProvider.autoDispose.family<ItemViewModel, String>((ref, id) async {
  final ItemViewModelList items = await ref.watch(itemsProvider.future);

  return items.firstWhere((ItemModel element) => element.id == id);
});

final selectedItemStateProvider =
    StateNotifierProvider.autoDispose.family<PreserveStateNotifier<ItemViewModel>, AsyncValue<ItemViewModel>, String>(
  (ref, id) => PreserveStateNotifier(_selectedItemProvider(id), ref),
);
