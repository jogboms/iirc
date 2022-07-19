import 'package:equatable/equatable.dart';

import '../models/tag.dart';

class CreateItemData with EquatableMixin {
  const CreateItemData({
    required this.description,
    required this.date,
    required this.tag,
  });

  final String description;
  final DateTime date;
  final TagModel? tag;

  @override
  List<Object?> get props => <Object?>[description, date, tag];

  @override
  bool? get stringify => true;
}
