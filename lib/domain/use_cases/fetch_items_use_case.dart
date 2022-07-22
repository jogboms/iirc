import '../models/item.dart';
import '../repositories/items.dart';

class FetchItemsUseCase {
  const FetchItemsUseCase({required ItemsRepository items}) : _items = items;

  final ItemsRepository _items;

  Stream<ItemModelList> call(String userId) => _items.fetch(userId);
}
