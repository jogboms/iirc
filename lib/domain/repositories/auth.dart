import '../models/account.dart';

abstract class AuthRepository {
  Future<AccountModel> get account;

  Future<String> signIn({required String email, required String password});

  Stream<String> get onAuthStateChanged;

  Future<void> signOut();
}
