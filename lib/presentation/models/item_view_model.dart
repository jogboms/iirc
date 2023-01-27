import 'package:equatable/equatable.dart';
import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';

import 'tag_view_model.dart';

class ItemViewModel with EquatableMixin {
  @visibleForTesting
  const ItemViewModel({
    required this.id,
    required this.date,
    required this.description,
    required this.path,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
  });

  static ItemViewModel fromItem(NormalizedItemEntity item) => ItemViewModel(
        id: item.id,
        path: item.path,
        description: item.description,
        date: item.date,
        tag: TagViewModel.fromTag(item.tag),
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
      );

  final String id;
  final String path;
  final String description;
  final DateTime date;
  final TagViewModel tag;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[id, path, description, date, tag, createdAt, updatedAt];
}

typedef ItemViewModelList = List<ItemViewModel>;
