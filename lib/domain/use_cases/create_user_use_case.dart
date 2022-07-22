import '../models/account.dart';
import '../repositories/users.dart';

class CreateUserUseCase {
  const CreateUserUseCase({required UsersRepository users}) : _users = users;

  final UsersRepository _users;

  Future<String> call(AccountModel account) => _users.create(account);
}
