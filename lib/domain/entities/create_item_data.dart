import 'package:equatable/equatable.dart';

import 'tag_reference_entity.dart';

class CreateItemData with EquatableMixin {
  const CreateItemData({
    required this.description,
    required this.date,
    required this.tag,
  });

  final String description;
  final DateTime date;
  final TagReferenceEntity tag;

  @override
  List<Object> get props => <Object>[description, date, tag];
}
