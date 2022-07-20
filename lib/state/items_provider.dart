// ignore_for_file: always_specify_types

import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:riverpod/riverpod.dart';

import 'registry_provider.dart';

final itemsProvider = StreamProvider<ItemViewModelList>((ref) {
  final registry = ref.read(registryProvider);
  return registry.get<FetchItemsUseCase>().call().map((element) => element.map(ItemViewModel.fromItem).toList());
});
