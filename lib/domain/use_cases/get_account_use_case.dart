import '../models/account.dart';
import '../repositories/auth.dart';

class GetAccountUseCase {
  const GetAccountUseCase({required AuthRepository auth}) : _auth = auth;

  final AuthRepository _auth;

  Future<AccountModel> call() => _auth.account;
}
