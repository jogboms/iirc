// ignore_for_file: always_specify_types

import 'dart:async';

import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../../../state.dart';

final itemProvider = Provider.autoDispose<ItemProvider>((ref) {
  final di = ref.read(registryProvider).get;

  return ItemProvider(
    analytics: di(),
    fetchUser: () => ref.read(userProvider.future),
    createItemUseCase: di(),
    deleteItemUseCase: di(),
    updateItemUseCase: di(),
  );
});

@visibleForTesting
class ItemProvider {
  const ItemProvider({
    required this.analytics,
    required this.fetchUser,
    required this.createItemUseCase,
    required this.updateItemUseCase,
    required this.deleteItemUseCase,
  });

  final Analytics analytics;
  final Future<UserModel> Function() fetchUser;
  final CreateItemUseCase createItemUseCase;
  final UpdateItemUseCase updateItemUseCase;
  final DeleteItemUseCase deleteItemUseCase;

  Future<String> create(CreateItemData data) async {
    final userId = (await fetchUser()).id;
    unawaited(analytics.log(AnalyticsEvent.createItem(userId)));
    return createItemUseCase(userId, data);
  }

  Future<bool> update(UpdateItemData data) async {
    unawaited(analytics.log(AnalyticsEvent.updateItem(data.path)));
    return updateItemUseCase(data);
  }

  Future<bool> delete(String path) async {
    unawaited(analytics.log(AnalyticsEvent.deleteTag(path)));
    return deleteItemUseCase(path);
  }
}
