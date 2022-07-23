import '../repositories/items.dart';

class DeleteItemUseCase {
  const DeleteItemUseCase({required ItemsRepository items}) : _items = items;

  final ItemsRepository _items;

  Future<bool> call(String path) => _items.delete(path);
}
