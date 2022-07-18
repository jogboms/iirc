import 'package:faker/faker.dart';
import 'package:iirc/domain.dart';

class AuthMockImpl extends AuthRepository {
  static final String id = faker.guid.guid();

  static AccountModel generateAccount() =>
      AccountModel(id: id, displayName: faker.person.name(), email: faker.internet.email());

  @override
  Future<AccountModel> get account async => generateAccount();

  @override
  Stream<String> get onAuthStateChanged async* {
    yield id;
  }

  @override
  Future<String> signIn({required String email, required String password}) async => id;

  @override
  Future<void> signOut() async {}
}
