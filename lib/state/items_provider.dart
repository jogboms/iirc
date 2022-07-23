// ignore_for_file: always_specify_types

import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:riverpod/riverpod.dart';

import 'registry_provider.dart';
import 'tags_provider.dart';
import 'user_provider.dart';

final itemsProvider = StreamProvider.autoDispose<ItemViewModelList>((ref) async* {
  final registry = ref.read(registryProvider);
  final user = await ref.watch(userProvider.future);
  final tags = await ref.watch(tagsProvider.future);

  yield* registry.get<FetchItemsUseCase>().call(user.id).map((element) =>
      element.map((item) => ItemViewModel.fromItem(item, tags.firstWhere((tag) => tag.id == item.tag.id))).toList());
});
