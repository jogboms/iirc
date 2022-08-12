import 'package:clock/clock.dart';
import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue, Timestamp;
import 'package:iirc/domain.dart';
import 'package:uuid/uuid.dart';

import '../../network/firebase/cloud_db.dart';
import '../../network/firebase/firebase.dart';
import '../../network/firebase/models.dart';
import '../derive_date_from_timestamp.dart';
import '../extensions.dart';

class ItemsFirebaseImpl implements ItemsRepository {
  ItemsFirebaseImpl({
    required Firebase firebase,
    required this.isDev,
  }) : stores = FireStoreDb(firebase.db.instance, collectionName);

  static const String collectionName = 'items';

  final FireStoreDb stores;
  final bool isDev;

  @override
  Future<String> create(String userId, CreateItemData item) async {
    final String id = const Uuid().v4();
    await stores.instance.doc(stores.deriveEntriesPath(userId, id)).set(<String, dynamic>{
      'description': item.description,
      'date': Timestamp.fromDate(item.date.toUtc()),
      'tag': stores.instance.doc(item.tag.path),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  @override
  Future<bool> delete(String path) async {
    await stores.instance.doc(path).delete();
    return true;
  }

  @override
  Future<bool> update(UpdateItemData item) async {
    await stores.instance.doc(item.path).update(<String, dynamic>{
      'description': item.description,
      'date': Timestamp.fromDate(item.date.toUtc()),
      'tag': stores.instance.doc(item.tag.path),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  @override
  Stream<ItemModelList> fetch(String userId) =>
      stores.fetchEntries(userId: userId, orderBy: 'date', mapper: _deriveItemFromDocument, isDev: isDev);
}

Future<ItemModel> _deriveItemFromDocument(MapDocumentSnapshot document) async {
  final DynamicMap data = document.data()!;
  final MapDocumentReference tag = data['tag'] as MapDocumentReference;

  return ItemModel(
    id: document.id,
    path: document.reference.path,
    description: data['description'] as String,
    date: deriveDateFromTimestamp(data['date'] as Timestamp),
    tag: TagModelReference(id: tag.id, path: tag.path),
    createdAt: data['createdAt'] != null ? deriveDateFromTimestamp(data['createdAt'] as Timestamp) : clock.now(),
    updatedAt: data['updatedAt'] != null ? deriveDateFromTimestamp(data['updatedAt'] as Timestamp) : null,
  );
}
