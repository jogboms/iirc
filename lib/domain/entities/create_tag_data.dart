import 'package:equatable/equatable.dart';

class CreateTagData with EquatableMixin {
  const CreateTagData({
    required this.title,
    required this.description,
    required this.color,
  });

  final String title;
  final String description;
  final int color;

  @override
  List<Object> get props => <Object>[title, description, color];

  @override
  bool? get stringify => true;
}
