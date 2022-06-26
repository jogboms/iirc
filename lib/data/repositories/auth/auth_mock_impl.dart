import 'package:faker/faker.dart';
import 'package:iirc/domain.dart';

class AuthMockImpl extends AuthRepository {
  static final String id = faker.guid.guid();

  @override
  Future<AccountModel> get account async =>
      AccountModel(id: id, displayName: faker.person.name(), email: faker.internet.email());

  @override
  Stream<String> get onAuthStateChanged async* {
    yield id;
  }

  @override
  Future<String> signIn({required String email, required String password}) async => id;

  @override
  Future<void> signOut() async {}
}
