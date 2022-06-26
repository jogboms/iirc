import 'package:equatable/equatable.dart';

class AccountModel with EquatableMixin {
  const AccountModel({
    required this.id,
    required this.displayName,
    required this.email,
  });

  final String id;
  final String? displayName;
  final String email;

  @override
  List<Object?> get props => <Object?>[id, displayName, email];

  @override
  bool? get stringify => true;
}
