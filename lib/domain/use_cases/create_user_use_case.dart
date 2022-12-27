import '../entities/account_entity.dart';
import '../repositories/users.dart';

class CreateUserUseCase {
  const CreateUserUseCase({required UsersRepository users}) : _users = users;

  final UsersRepository _users;

  Future<String> call(AccountEntity account) => _users.create(account);
}
