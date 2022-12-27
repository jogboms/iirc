import 'package:equatable/equatable.dart';

import 'tag_reference_entity.dart';

class UpdateItemData with EquatableMixin {
  const UpdateItemData({
    required this.id,
    required this.path,
    required this.description,
    required this.date,
    required this.tag,
  });

  final String id;
  final String path;
  final String description;
  final DateTime date;
  final TagReferenceEntity tag;

  @override
  List<Object?> get props => <Object?>[id, path, description, date, tag];
}
