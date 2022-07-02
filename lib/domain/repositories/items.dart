import '../entities/create_item_data.dart';
import '../entities/update_item_data.dart';
import '../models/item.dart';

abstract class ItemsRepository {
  Future<ItemModel> create(String userId, CreateItemData item);

  Future<bool> update(UpdateItemData item);

  Future<bool> delete(String path);

  Stream<ItemModelList> fetch();
}
