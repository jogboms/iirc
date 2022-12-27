import '../entities/account_entity.dart';
import '../repositories/auth.dart';

class GetAccountUseCase {
  const GetAccountUseCase({required AuthRepository auth}) : _auth = auth;

  final AuthRepository _auth;

  Future<AccountEntity> call() => _auth.fetch();
}
