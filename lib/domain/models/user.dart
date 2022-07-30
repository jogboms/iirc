import 'package:equatable/equatable.dart';

class UserModel with EquatableMixin {
  const UserModel({
    required this.id,
    required this.path,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.lastSeenAt,
    required this.createdAt,
  });

  final String id;
  final String path;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime lastSeenAt;
  final DateTime createdAt;

  @override
  List<Object> get props => <Object>[id, path, email, firstName, lastName, lastSeenAt, createdAt];

  @override
  bool? get stringify => true;
}
