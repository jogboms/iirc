import '../entities/update_user_data.dart';
import '../models/account.dart';
import '../models/user.dart';

abstract class UsersRepository {
  Future<String> create(AccountModel account);

  Future<bool> update(UpdateUserData user);

  Future<UserModel?> fetch(String uid);
}
