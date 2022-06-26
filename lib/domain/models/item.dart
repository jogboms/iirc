import 'package:equatable/equatable.dart';

import 'tag.dart';

class ItemModel with EquatableMixin {
  const ItemModel({
    required this.id,
    required this.path,
    required this.title,
    required this.description,
    required this.date,
    required this.tag,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String path;
  final String title;
  final String description;
  final DateTime date;
  final TagModel tag;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => <Object?>[id, path, title, description, date, tag, createdAt, updatedAt];

  @override
  bool? get stringify => true;
}
