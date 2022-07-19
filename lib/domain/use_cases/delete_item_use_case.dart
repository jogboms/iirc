import '../models/item.dart';
import '../repositories/items.dart';

class DeleteItemUseCase {
  const DeleteItemUseCase({required ItemsRepository items}) : _items = items;

  final ItemsRepository _items;

  Future<bool> call(ItemModel item) => _items.delete(item.path);
}
