import '../entities/update_item_data.dart';
import '../repositories/items.dart';

class UpdateItemUseCase {
  const UpdateItemUseCase({required ItemsRepository items}) : _items = items;

  final ItemsRepository _items;

  Future<bool> call(UpdateItemData tag) => _items.update(tag);
}
