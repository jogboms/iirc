import '../entities/create_item_data.dart';
import '../entities/item_entity.dart';
import '../entities/update_item_data.dart';

abstract class ItemsRepository {
  Future<String> create(String userId, CreateItemData item);

  Future<bool> update(UpdateItemData item);

  Future<bool> delete(String path);

  Stream<ItemEntityList> fetch(String userId);
}
