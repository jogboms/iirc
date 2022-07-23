import 'package:iirc/domain.dart';

import 'tag_view_model.dart';

class ItemViewModel extends BaseItemModel<TagViewModel> {
  const ItemViewModel._({
    required super.id,
    required super.date,
    required super.description,
    required super.path,
    required super.tag,
    required super.createdAt,
    required super.updatedAt,
  });

  static ItemViewModel fromItem(NormalizedItemModel item) => ItemViewModel._(
        id: item.id,
        path: item.path,
        description: item.description,
        date: item.date,
        tag: TagViewModel.fromTag(item.tag),
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );
}

typedef ItemViewModelList = List<ItemViewModel>;
