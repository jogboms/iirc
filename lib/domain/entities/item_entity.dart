import 'package:equatable/equatable.dart';

import 'tag_entity.dart';
import 'tag_reference_entity.dart';

class BaseItemEntity<T> with EquatableMixin {
  const BaseItemEntity({
    required this.id,
    required this.path,
    required this.description,
    required this.date,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String path;
  final String description;
  final DateTime date;
  final T tag;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[id, path, description, date, tag, createdAt, updatedAt];

  @override
  bool? get stringify => true;
}

typedef ItemEntity = BaseItemEntity<TagReferenceEntity>;
typedef NormalizedItemEntity = BaseItemEntity<TagEntity>;

typedef ItemEntityList = List<ItemEntity>;
typedef NormalizedItemEntityList = List<NormalizedItemEntity>;
