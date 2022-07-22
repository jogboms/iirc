import '../entities/create_item_data.dart';
import '../repositories/items.dart';

class CreateItemUseCase {
  const CreateItemUseCase({required ItemsRepository items}) : _items = items;

  final ItemsRepository _items;

  Future<String> call(String userId, CreateItemData item) => _items.create(userId, item);
}
