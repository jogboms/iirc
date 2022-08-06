import 'package:iirc/core.dart';

import '../models/user.dart';
import '../repositories/users.dart';

class FetchUserUseCase {
  const FetchUserUseCase({required UsersRepository users}) : _users = users;

  final UsersRepository _users;

  Future<UserModel?> call(String uid) async {
    try {
      return _users.fetch(uid);
    } catch (error, stackTrace) {
      AppLog.e(error, stackTrace);
      return null;
    }
  }
}
