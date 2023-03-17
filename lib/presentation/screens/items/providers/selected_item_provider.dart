// ignore_for_file: always_specify_types

import 'package:riverpod/riverpod.dart';

import '../../../models.dart';
import '../../../state.dart';

final selectedItemProvider = FutureProvider.autoDispose.family<ItemViewModel, String>((ref, id) async {
  final ItemViewModelList items = await ref.watch(itemsProvider.future);

  return items.firstWhere((ItemViewModel element) => element.id == id);
});
