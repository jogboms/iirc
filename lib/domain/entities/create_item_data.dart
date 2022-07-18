import 'package:equatable/equatable.dart';

import '../models/tag.dart';

class CreateItemData with EquatableMixin {
  const CreateItemData({
    required this.description,
    required this.date,
    required this.tag,
  });

  final String? description;
  final DateTime? date;
  final TagModel? tag;

  CreateItemData copyWith({
    String? description,
    DateTime? date,
    TagModel? tag,
  }) =>
      CreateItemData(
        description: description ?? this.description,
        date: date ?? this.date,
        tag: tag ?? this.tag,
      );

  @override
  List<Object?> get props => <Object?>[description, date, tag];

  bool get isValid => props.every((Object? item) => item != null);

  @override
  bool? get stringify => true;
}
