import 'package:clock/clock.dart';
import 'package:equatable/equatable.dart';

import '../../data/network/firebase/models.dart';
import '../../data/repositories/derive_date_from_timestamp.dart';

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
  factory TagModel.fromJson(
    String id,
    String path,
    DynamicMap data,
  ) =>
      TagModel(
        id: id,
        path: path,
        title: data['title'] as String,
        description: data['description'] as String,
        color: data['color'] as int,
        createdAt: data['createdAt'] != null
            ? deriveDateFromTimestamp(data['createdAt'] as CloudTimestamp)
            : clock.now(),
        updatedAt: data['updatedAt'] != null
            ? deriveDateFromTimestamp(data['updatedAt'] as CloudTimestamp)
            : null,
      );

  final String id;
  final String path;
  final String title;
  final String description;
  final int color;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props =>
      <Object?>[id, path, title, description, color, createdAt, updatedAt];

  @override
  bool? get stringify => true;
}

typedef TagModelList = List<TagModel>;
