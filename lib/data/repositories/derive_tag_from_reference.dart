import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/tag.dart';
import '../network/firebase/models.dart';
import 'derive_tag_model_from_json.dart';

final Map<String, TagModel> _memoizedTags = <String, TagModel>{};

Future<TagModel> deriveTagFromReference(MapDocumentReference reference) async {
  if (_memoizedTags.containsKey(reference.id)) {
    return _memoizedTags[reference.id]!;
  }
  final DocumentSnapshot<Object?> item = await reference.get();
  final TagModel user = await deriveTagModelFromJson(reference.id, reference.path, item.data()! as DynamicMap);
  _memoizedTags[reference.id] = user;
  return user;
}
