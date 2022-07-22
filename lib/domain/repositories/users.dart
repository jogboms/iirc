import '../models/account.dart';
import '../models/user.dart';

abstract class UsersRepository {
  Future<String> create(AccountModel account);

  Future<UserModel?> fetch(String uid);
}
