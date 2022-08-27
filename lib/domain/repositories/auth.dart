import '../models/account.dart';

abstract class AuthRepository {
  Future<AccountModel> fetch();

  Future<String> signIn();

  Stream<String?> get onAuthStateChanged;

  Future<void> signOut();
}
