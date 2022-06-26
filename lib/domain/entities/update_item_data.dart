import 'package:equatable/equatable.dart';

import '../models/tag.dart';

class UpdateItemData with EquatableMixin {
  const UpdateItemData({
    required this.id,
    required this.path,
    required this.title,
    required this.description,
    required this.date,
    required this.tag,
  });

  final String id;
  final String path;
  final String title;
  final String description;
  final DateTime date;
  final TagModel tag;

  UpdateItemData copyWith({
    String? title,
    String? description,
    DateTime? date,
    TagModel? tag,
  }) =>
      UpdateItemData(
        id: id,
        path: path,
        title: title ?? this.title,
        description: description ?? this.description,
        date: date ?? this.date,
        tag: tag ?? this.tag,
      );

  @override
  List<Object?> get props => <Object?>[id, path, title, description, date, tag];

  @override
  bool? get stringify => true;
}
