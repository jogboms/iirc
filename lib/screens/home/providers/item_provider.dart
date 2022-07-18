// ignore_for_file: always_specify_types

import 'package:flutter/widgets.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final itemProvider = Provider.autoDispose<ItemProvider>(ItemProvider.new);

@visibleForTesting
class ItemProvider {
  const ItemProvider(AutoDisposeProviderRef ref) : _ref = ref;

  final AutoDisposeProviderRef _ref;

  Future<ItemModel> create(CreateItemData data) async {
    final registry = _ref.read(registryProvider);
    final user = await _ref.read(userProvider.future);

    return registry.get<CreateItemUseCase>().call(user.id, data);
  }
}
