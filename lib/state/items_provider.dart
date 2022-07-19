// ignore_for_file: always_specify_types

import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final itemsProvider = StreamProvider<ItemViewModelList>((ref) {
  final Registry registry = ref.read(registryProvider);
  return registry.get<FetchItemsUseCase>().call().map((element) => element.map(ItemViewModel.fromItem).toList());
});
