import 'package:equatable/equatable.dart';

import 'tag_reference_entity.dart';

class TagEntity with EquatableMixin {
  const TagEntity({
    required this.id,
    required this.path,
    required this.title,
    required this.description,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String path;
  final String title;
  final String description;
  final int color;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[id, path, title, description, color, createdAt, updatedAt];

  @override
  bool? get stringify => true;
}

extension TagReferenceEntityExtension on TagEntity {
  TagReferenceEntity get reference => TagReferenceEntity(id: id, path: path);
}

typedef TagEntityList = List<TagEntity>;
