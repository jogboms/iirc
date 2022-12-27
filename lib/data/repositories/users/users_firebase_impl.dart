import 'package:iirc/domain.dart';

import '../../network/firebase/cloud_db.dart';
import '../../network/firebase/firebase.dart';
import '../../network/firebase/models.dart';
import '../derive_date_from_timestamp.dart';

class UsersFirebaseImpl implements UsersRepository {
  UsersFirebaseImpl({required Firebase firebase}) : collection = CloudDbCollection(firebase.db, collectionName);

  static const String collectionName = 'users';

  final CloudDbCollection collection;

  @override
  Future<String> create(AccountEntity account) async {
    final List<String>? names = account.displayName?.split(' ');
    await collection.fetchOne(account.id).set(<String, Object>{
      'email': account.email,
      'firstName': names?.first ?? '',
      'lastName': names != null && names.length > 1 ? names.sublist(1).join(' ') : '',
      'lastSeenAt': CloudValue.serverTimestamp(),
      'createdAt': CloudValue.serverTimestamp(),
    });
    return account.id;
  }

  @override
  Future<bool> update(UpdateUserData user) async {
    await collection.fetchOne(user.id).update(<String, Object>{
      'lastSeenAt': CloudTimestamp.fromDate(user.lastSeenAt.toUtc()),
    });
    return true;
  }

  @override
  Future<UserEntity?> fetch(String uid) async {
    final MapDocumentSnapshot doc = await collection.fetchOne(uid).get();
    if (!doc.exists) {
      return null;
    }

    return _deriveUserModelFromJson(doc.id, doc.reference.path, doc.data()!);
  }
}

Future<UserEntity> _deriveUserModelFromJson(String id, String path, DynamicMap data) async => UserEntity(
      id: id,
      path: path,
      email: data['email'] as String,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      lastSeenAt: deriveDateFromTimestamp(data['lastSeenAt'] as CloudTimestamp),
      createdAt: deriveDateFromTimestamp(data['createdAt'] as CloudTimestamp),
    );
