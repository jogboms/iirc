import 'package:faker/faker.dart';
import 'package:iirc/domain.dart';
import 'package:rxdart/subjects.dart';

class AuthMockImpl extends AuthRepository {
  static final String id = faker.guid.guid();

  static AccountModel generateAccount() =>
      AccountModel(id: id, displayName: faker.person.name(), email: faker.internet.email());

  final BehaviorSubject<String?> _authIdState$ = BehaviorSubject<String?>();

  @override
  Future<AccountModel> fetch() async => generateAccount();

  @override
  Stream<String?> get onAuthStateChanged => _authIdState$;

  @override
  Future<String> signIn() async {
    _authIdState$.add(id);
    return id;
  }

  @override
  Future<void> signOut() async {
    _authIdState$.add(null);
  }
}
