import 'package:equatable/equatable.dart';

class CreateItemData with EquatableMixin {
  const CreateItemData({
    required this.description,
    required this.date,
    required this.tagId,
    required this.tagPath,
  });

  final String description;
  final DateTime date;
  final String tagId;
  final String tagPath;

  @override
  List<Object> get props => <Object>[description, date, tagId, tagPath];
}
