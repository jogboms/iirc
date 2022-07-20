import '../models/account.dart';

abstract class AuthRepository {
  Future<AccountModel> get account;

  Future<String> signIn();

  Stream<String?> get onAuthStateChanged;

  Future<void> signOut();
}
