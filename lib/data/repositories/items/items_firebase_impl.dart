import 'package:clock/clock.dart';
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
    this.idGenerator,
  }) : items = CloudDbCollection(firebase.db, collectionName);

  static const String collectionName = 'items';

  final CloudDbCollection items;
  final bool isDev;
  final String Function()? idGenerator;

  @override
  Future<String> create(String userId, CreateItemData item) async {
    final String id = idGenerator?.call() ?? const Uuid().v4();
    await items.db.doc(items.deriveEntriesPath(userId, id)).set(<String, dynamic>{
      'description': item.description,
      'date': CloudTimestamp.fromDate(item.date.toUtc()),
      'tag': items.db.doc(item.tag.path),
      'createdAt': CloudValue.serverTimestamp(),
    });
    return id;
  }

  @override
  Future<bool> delete(String path) async {
    await items.db.doc(path).delete();
    return true;
  }

  @override
  Future<bool> update(UpdateItemData item) async {
    await items.db.doc(item.path).update(<String, dynamic>{
      'description': item.description,
      'date': CloudTimestamp.fromDate(item.date.toUtc()),
      'tag': items.db.doc(item.tag.path),
      'updatedAt': CloudValue.serverTimestamp(),
    });
    return true;
  }

  @override
  Stream<ItemModelList> fetch(String userId) =>
      items.fetchEntries(userId: userId, orderBy: 'date', mapper: _deriveItemFromDocument, isDev: isDev);
}

Future<ItemModel> _deriveItemFromDocument(MapDocumentSnapshot document) async {
  final DynamicMap data = document.data()!;
  final MapDocumentReference tag = data['tag'] as MapDocumentReference;

  return ItemModel(
    id: document.id,
    path: document.reference.path,
    description: data['description'] as String,
    date: deriveDateFromTimestamp(data['date'] as CloudTimestamp),
    tag: TagModelReference(id: tag.id, path: tag.path),
    createdAt: data['createdAt'] != null ? deriveDateFromTimestamp(data['createdAt'] as CloudTimestamp) : clock.now(),
    updatedAt: data['updatedAt'] != null ? deriveDateFromTimestamp(data['updatedAt'] as CloudTimestamp) : null,
  );
}
