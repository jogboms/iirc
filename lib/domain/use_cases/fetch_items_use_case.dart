import 'package:rxdart/streams.dart';

import '../models/item.dart';
import '../models/tag.dart';
import '../repositories/items.dart';
import '../repositories/tags.dart';

class FetchItemsUseCase {
  const FetchItemsUseCase({required ItemsRepository items, required TagsRepository tags})
      : _items = items,
        _tags = tags;

  final ItemsRepository _items;
  final TagsRepository _tags;

  Stream<NormalizedItemModelList> call(String userId) =>
      CombineLatestStream.combine2<ItemModelList, TagModelList, NormalizedItemModelList>(
        _items.fetch(userId),
        _tags.fetch(userId),
        (ItemModelList items, TagModelList tags) => items
            .map((ItemModel item) => NormalizedItemModel(
                  id: item.id,
                  path: item.path,
                  description: item.description,
                  date: item.date,
                  tag: tags.firstWhere((TagModel tag) => tag.id == item.tag.id),
                  createdAt: item.createdAt,
                  updatedAt: item.updatedAt,
                ))
            .toList(),
      );
}
