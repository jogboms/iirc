import 'dart:async';

import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../registry.dart';
import '../../../state.dart';

part 'item_provider.g.dart';

@Riverpod(dependencies: <Object>[registry, user])
ItemProvider item(ItemRef ref) {
  final RegistryFactory di = ref.read(registryProvider).get;

  return ItemProvider(
    fetchUser: () => ref.read(userProvider.future),
    createItemUseCase: di(),
    deleteItemUseCase: di(),
    updateItemUseCase: di(),
  );
}

@visibleForTesting
class ItemProvider {
  const ItemProvider({
    required this.fetchUser,
    required this.createItemUseCase,
    required this.updateItemUseCase,
    required this.deleteItemUseCase,
  });

  final Future<UserEntity> Function() fetchUser;
  final CreateItemUseCase createItemUseCase;
  final UpdateItemUseCase updateItemUseCase;
  final DeleteItemUseCase deleteItemUseCase;

  Future<String> create(CreateItemData data) async {
    final String userId = (await fetchUser()).id;
    return createItemUseCase(userId, data);
  }

  Future<bool> update(UpdateItemData data) async => updateItemUseCase(data);

  Future<bool> delete(String path) async => deleteItemUseCase(path);
}
