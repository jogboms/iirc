import 'package:equatable/equatable.dart';

class UpdateTagData with EquatableMixin {
  const UpdateTagData({
    required this.id,
    required this.path,
    required this.title,
    required this.description,
    required this.color,
  });

  final String id;
  final String path;
  final String title;
  final String description;
  final int color;

  @override
  List<Object?> get props => <Object?>[id, path, title, description, color];

  @override
  bool? get stringify => true;
}
