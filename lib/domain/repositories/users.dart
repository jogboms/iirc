import '../models/user.dart';

abstract class UsersRepository {
  Future<UserModel> fetch(String uid);
}
