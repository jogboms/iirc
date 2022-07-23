import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import 'tag.dart';

@optionalTypeArgs
abstract class ItemModelInterface<T> {
  String get id;

  String get path;

  String get description;

  DateTime get date;

  T get tag;

  DateTime get createdAt;

  DateTime? get updatedAt;
}

class ItemModel with EquatableMixin implements ItemModelInterface<TagModelReference> {
  const ItemModel({
    required this.id,
    required this.path,
    required this.description,
    required this.date,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  final String id;
  @override
  final String path;
  @override
  final String description;
  @override
  final DateTime date;
  @override
  final TagModelReference tag;
  @override
  final DateTime createdAt;
  @override
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[id, path, description, date, tag, createdAt, updatedAt];

  @override
  bool? get stringify => true;
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
