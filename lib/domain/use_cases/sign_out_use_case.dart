import '../repositories/auth.dart';

class SignOutUseCase {
  const SignOutUseCase({required AuthRepository auth}) : _auth = auth;

  final AuthRepository _auth;

  Future<void> call() => _auth.signOut();
}
