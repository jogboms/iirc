import 'package:equatable/equatable.dart';

class UpdateItemData with EquatableMixin {
  const UpdateItemData({
    required this.id,
    required this.path,
    required this.description,
    required this.date,
    required this.tagId,
    required this.tagPath,
  });

  final String id;
  final String path;
  final String description;
  final DateTime date;
  final String tagId;
  final String tagPath;

  @override
  List<Object?> get props => <Object?>[id, path, description, date, tagId, tagPath];
}
