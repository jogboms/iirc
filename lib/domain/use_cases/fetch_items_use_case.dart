import 'package:rxdart/streams.dart';

import '../entities/item_entity.dart';
import '../entities/tag_entity.dart';
import '../repositories/items.dart';
import '../repositories/tags.dart';

class FetchItemsUseCase {
  const FetchItemsUseCase({required ItemsRepository items, required TagsRepository tags})
      : _items = items,
        _tags = tags;

  final ItemsRepository _items;
  final TagsRepository _tags;

  Stream<NormalizedItemEntityList> call(String userId) =>
      CombineLatestStream.combine2<ItemEntityList, TagEntityList, NormalizedItemEntityList>(
        _items.fetch(userId),
        _tags.fetch(userId),
        (ItemEntityList items, TagEntityList tags) => items
            .map(
              (ItemEntity item) => NormalizedItemEntity(
                id: item.id,
                path: item.path,
                description: item.description,
                date: item.date,
                tag: tags.firstWhere((TagEntity tag) => tag.id == item.tag.id),
                createdAt: item.createdAt,
                updatedAt: item.updatedAt,
              ),
            )
            .toList(),
      );
}
