import 'package:iirc/domain.dart';
import 'package:iirc/registry.dart';
import 'package:iirc/state.dart';
import 'package:riverpod/riverpod.dart';

final _Provider itemsProvider = _Provider((StreamProviderRef<ItemModelList> ref) {
  final Registry registry = ref.read(registryProvider);
  return registry.get<FetchItemsUseCase>().call();
});

final _Provider filteredItemsProvider = _Provider((StreamProviderRef<ItemModelList> ref) {
  return ref.watch(itemsProvider.stream).map((ItemModelList items) => items.uniqueByTag());
});

typedef _Provider = StreamProvider<ItemModelList>;

extension UniqueByTagExtension<E extends ItemModel> on Iterable<E> {
  List<E> uniqueByTag() => fold(
        <String, E>{},
        (Map<String, E> previousValue, E element) => previousValue..putIfAbsent(element.tag.id, () => element),
      ).values.toList(growable: false);
}
