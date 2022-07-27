import 'package:equatable/equatable.dart';

import 'tag.dart';

class BaseItemModel<T> with EquatableMixin {
  const BaseItemModel({
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

class ItemModel extends BaseItemModel<TagModelReference> {
  const ItemModel({
    required super.id,
    required super.path,
    required super.description,
    required super.date,
    required super.tag,
    required super.createdAt,
    required super.updatedAt,
  });
}

class NormalizedItemModel extends BaseItemModel<TagModel> {
  const NormalizedItemModel({
    required super.id,
    required super.path,
    required super.description,
    required super.date,
    required super.tag,
    required super.createdAt,
    required super.updatedAt,
  });
}

class TagModelReference with EquatableMixin {
  const TagModelReference({required this.id, required this.path});

  final String id;
  final String path;

  @override
  List<Object> get props => <Object>[id, path];

  @override
  bool? get stringify => true;
}

extension TagModelReferenceExtension on TagModel {
  TagModelReference get reference => TagModelReference(id: id, path: path);
}

typedef ItemModelList = List<ItemModel>;
typedef NormalizedItemModelList = List<NormalizedItemModel>;
