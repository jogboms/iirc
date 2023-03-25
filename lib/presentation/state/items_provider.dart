import 'package:iirc/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models.dart';
import '../registry.dart';
import 'registry_provider.dart';
import 'user_provider.dart';

part 'items_provider.g.dart';

@Riverpod(dependencies: <Object>[registry, user])
Stream<ItemViewModelList> items(ItemsRef ref) async* {
  final Registry registry = ref.read(registryProvider);
  final UserEntity user = await ref.watch(userProvider.future);

  yield* registry
      .get<FetchItemsUseCase>()
      .call(user.id)
      .map((NormalizedItemEntityList element) => element.map(ItemViewModel.fromItem).toList());
}
