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

  CreateTagData copyWith({
    String? title,
    String? description,
    int? color,
  }) =>
      CreateTagData(
        title: title ?? this.title,
        description: description ?? this.description,
        color: color ?? this.color,
      );

  @override
  List<Object> get props => <Object>[title, description, color];

  bool get isValid => props.every((Object? item) => item != null);

  @override
  bool? get stringify => true;
}
