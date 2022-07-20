import '../repositories/auth.dart';

class SignInUseCase {
  const SignInUseCase({required AuthRepository auth}) : _auth = auth;

  final AuthRepository _auth;

  Future<String> call() => _auth.signIn();
}
