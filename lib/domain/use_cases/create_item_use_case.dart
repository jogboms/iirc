import '../entities/create_item_data.dart';
import '../models/item.dart';
import '../repositories/items.dart';

class CreateItemUseCase {
  const CreateItemUseCase({required ItemsRepository items}) : _items = items;

  final ItemsRepository _items;

  Future<ItemModel> call(String userId, CreateItemData item) => _items.create(userId, item);
}
