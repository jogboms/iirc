import '../models/item.dart';
import '../repositories/items.dart';

class DeleteItemUseCase {
  const DeleteItemUseCase({required ItemsRepository items}) : _items = items;

  final ItemsRepository _items;

  Future<bool> call(ItemModelInterface item) => _items.delete(item.path);
}
