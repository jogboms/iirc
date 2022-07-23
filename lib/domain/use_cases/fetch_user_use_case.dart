import '../models/user.dart';
import '../repositories/users.dart';

class FetchUserUseCase {
  const FetchUserUseCase({required UsersRepository users}) : _users = users;

  final UsersRepository _users;

  Future<UserModel?> call(String uid) async {
    try {
      return _users.fetch(uid);
    } catch (e) {
      // TODO: log this
      return null;
    }
  }
}
