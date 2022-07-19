// ignore_for_file: always_specify_types

import 'package:flutter/widgets.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final tagProvider = Provider.autoDispose<TagProvider>(TagProvider.new);

@visibleForTesting
class TagProvider {
  const TagProvider(AutoDisposeProviderRef ref) : _ref = ref;

  final AutoDisposeProviderRef _ref;

  Future<TagModel> create(CreateTagData data) async {
    final registry = _ref.read(registryProvider);
    final user = await _ref.read(userProvider.future);

    return registry.get<CreateTagUseCase>().call(user.id, data);
  }

  Future<bool> update(UpdateTagData data) async {
    final registry = _ref.read(registryProvider);
    return registry.get<UpdateTagUseCase>().call(data);
  }
}
