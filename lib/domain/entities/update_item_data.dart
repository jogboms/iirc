import 'package:equatable/equatable.dart';

import '../models/item.dart';

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
  final TagModelReference tag;

  @override
  List<Object?> get props => <Object?>[id, path, description, date, tag];

  @override
  bool? get stringify => true;
}
