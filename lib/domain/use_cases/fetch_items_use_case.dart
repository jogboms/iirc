import '../models/item.dart';
import '../repositories/items.dart';

class FetchItemsUseCase {
  const FetchItemsUseCase({required ItemsRepository items}) : _items = items;

  final ItemsRepository _items;

  Stream<List<ItemModel>> call() =>
      _items.fetch().map((List<ItemModel> items) => items.uniqueByTag()).asBroadcastStream();
}

extension UniqueByTagExtension<E extends ItemModel> on Iterable<E> {
  List<E> uniqueByTag() => fold(
        <String, E>{},
        (Map<String, E> previousValue, E element) => previousValue..putIfAbsent(element.tag.id, () => element),
      ).values.toList(growable: false);
}
