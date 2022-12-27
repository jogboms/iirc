import 'package:clock/clock.dart';
import 'package:iirc/domain.dart';
import 'package:uuid/uuid.dart';

import '../../network/firebase/cloud_db.dart';
import '../../network/firebase/firebase.dart';
import '../../network/firebase/models.dart';
import '../derive_date_from_timestamp.dart';
import '../extensions.dart';

class TagsFirebaseImpl implements TagsRepository {
  TagsFirebaseImpl({
    required Firebase firebase,
    required this.isDev,
    this.idGenerator,
  }) : tags = CloudDbCollection(firebase.db, collectionName);

  static const String collectionName = 'tags';

  final CloudDbCollection tags;
  final bool isDev;
  final String Function()? idGenerator;

  @override
  Future<String> create(String userId, CreateTagData tag) async {
    final String id = idGenerator?.call() ?? const Uuid().v4();
    await tags.db.doc(tags.deriveEntriesPath(userId, id)).set(<String, dynamic>{
      'title': tag.title,
      'description': tag.description,
      'color': tag.color,
      'createdAt': CloudValue.serverTimestamp(),
    });
    return id;
  }

  @override
  Future<bool> update(UpdateTagData tag) async {
    await tags.db.doc(tag.path).update(<String, dynamic>{
      'title': tag.title,
      'description': tag.description,
      'color': tag.color,
      'updatedAt': CloudValue.serverTimestamp(),
    });
    return true;
  }

  @override
  Future<bool> delete(String path) async {
    await tags.db.doc(path).delete();
    return true;
  }

  @override
  Stream<TagEntityList> fetch(String userId) =>
      tags.fetchEntries(userId: userId, mapper: _deriveTagFromDocument, isDev: isDev);
}

Future<TagEntity> _deriveTagFromDocument(MapDocumentSnapshot document) async {
  final DynamicMap data = document.data()!;

  return TagEntity(
    id: document.id,
    path: document.reference.path,
    title: data['title'] as String,
    description: data['description'] as String,
    color: data['color'] as int,
    createdAt: data['createdAt'] != null ? deriveDateFromTimestamp(data['createdAt'] as CloudTimestamp) : clock.now(),
    updatedAt: data['updatedAt'] != null ? deriveDateFromTimestamp(data['updatedAt'] as CloudTimestamp) : null,
  );
}
