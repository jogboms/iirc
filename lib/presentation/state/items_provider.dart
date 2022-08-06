// ignore_for_file: always_specify_types

import 'package:iirc/domain.dart';
import 'package:riverpod/riverpod.dart';

import '../models.dart';
import 'registry_provider.dart';
import 'user_provider.dart';

final itemsProvider = StreamProvider.autoDispose<ItemViewModelList>((ref) async* {
  final registry = ref.read(registryProvider);
  final user = await ref.watch(userProvider.future);

  yield* registry.get<FetchItemsUseCase>().call(user.id).map((element) => element.map(ItemViewModel.fromItem).toList());
});
