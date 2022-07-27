import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;
import 'package:iirc/domain.dart';
import 'package:uuid/uuid.dart';

import '../../network/firebase/cloud_db.dart';
import '../../network/firebase/firebase.dart';
import '../../network/firebase/models.dart';
import '../derive_tag_model_from_json.dart';
import '../extensions.dart';

class TagsFirebaseImpl implements TagsRepository {
  TagsFirebaseImpl({
    required Firebase firebase,
    required this.isDev,
  }) : stores = FireStoreDb(firebase.db.instance, collectionName);

  static const String collectionName = 'tags';

  final FireStoreDb stores;
  final bool isDev;

  @override
  Future<String> create(String userId, CreateTagData tag) async {
    final String id = const Uuid().v4();
    await stores.instance.doc(stores.deriveEntriesPath(userId, id)).set(<String, dynamic>{
      'title': tag.title,
      'description': tag.description,
      'color': tag.color,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return id;
  }

  @override
  Future<bool> update(UpdateTagData tag) async {
    await stores.instance.doc(tag.path).update(<String, dynamic>{
      'title': tag.title,
      'description': tag.description,
      'color': tag.color,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return true;
  }

  @override
  Future<bool> delete(String path) async {
    await stores.instance.doc(path).delete();
    return true;
  }

  @override
  Stream<TagModelList> fetch(String userId) =>
      stores.fetchEntries(userId: userId, mapper: _deriveTagFromDocument, isDev: isDev);
}

Future<TagModel> _deriveTagFromDocument(MapDocumentSnapshot document) async =>
    deriveTagModelFromJson(document.id, document.reference.path, document.data()!);
