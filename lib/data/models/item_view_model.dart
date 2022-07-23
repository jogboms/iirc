import 'package:equatable/equatable.dart';
import 'package:iirc/domain.dart';

import 'tag_view_model.dart';

class ItemViewModel with EquatableMixin implements ItemModelInterface<TagViewModel> {
  const ItemViewModel._({
    required this.id,
    required this.date,
    required this.description,
    required this.path,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
  });

  static ItemViewModel fromItem(ItemModel item, TagModel tag) => ItemViewModel._(
        id: item.id,
        path: item.path,
        description: item.description,
        date: item.date,
        tag: TagViewModel.fromTag(tag),
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );

  @override
  final String id;
  @override
  final String path;
  @override
  final String description;
  @override
  final DateTime date;
  @override
  final TagViewModel tag;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[id, path, description, date, tag, createdAt, updatedAt];

  @override
  bool? get stringify => true;
}

typedef ItemViewModelList = List<ItemViewModel>;
