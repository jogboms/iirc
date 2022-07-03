import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iirc/domain.dart';

import 'items_provider.dart';

final StateProvider<String> selectedItemIdProvider = StateProvider<String>((StateProviderRef<String> ref) => '');

final StateProvider<ItemModel?> selectedItemProvider = StateProvider<ItemModel?>((StateProviderRef<ItemModel?> ref) {
  final String id = ref.watch(selectedItemIdProvider);

  return ref.watch(itemsProvider).when(
        data: (ItemModelList data) => data.firstWhere((ItemModel element) => element.id == id),
        error: (Object error, _) => null,
        loading: () => null,
      );
});
