// ignore_for_file: always_specify_types

import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../../../state/registry_provider.dart';
import '../../../state/user_provider.dart';

final itemProvider = Provider.autoDispose<ItemProvider>((ref) {
  final di = ref.read(registryProvider).get;

  return ItemProvider(
    fetchUser: () => ref.read(userProvider.future),
    createItemUseCase: di(),
    deleteItemUseCase: di(),
    updateItemUseCase: di(),
  );
});

@visibleForTesting
class ItemProvider {
  const ItemProvider({
    required this.fetchUser,
    required this.createItemUseCase,
    required this.updateItemUseCase,
    required this.deleteItemUseCase,
  });

  final Future<UserModel> Function() fetchUser;
  final CreateItemUseCase createItemUseCase;
  final UpdateItemUseCase updateItemUseCase;
  final DeleteItemUseCase deleteItemUseCase;

  Future<String> create(CreateItemData data) async => createItemUseCase((await fetchUser()).id, data);

  Future<bool> update(UpdateItemData data) async => updateItemUseCase(data);

  Future<bool> delete(String path) async => deleteItemUseCase(path);
}
