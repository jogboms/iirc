import 'package:equatable/equatable.dart';

class TagModel with EquatableMixin {
  const TagModel({
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

typedef TagModelList = List<TagModel>;
