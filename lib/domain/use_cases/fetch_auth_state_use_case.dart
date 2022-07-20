import '../repositories/auth.dart';

class FetchAuthStateUseCase {
  const FetchAuthStateUseCase({required AuthRepository auth}) : _auth = auth;

  final AuthRepository _auth;

  Stream<String?> call() => _auth.onAuthStateChanged;
}
