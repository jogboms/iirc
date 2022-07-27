import '../../domain/models/tag.dart';
import '../network/firebase/models.dart';
import 'derive_tag_model_from_json.dart';

final Map<String, TagModel> _memoizedTags = <String, TagModel>{};

Future<TagModel> deriveTagFromReference(MapDocumentReference reference) async {
  if (_memoizedTags.containsKey(reference.id)) {
    return _memoizedTags[reference.id]!;
  }
  final MapDocumentSnapshot item = await reference.get();
  final TagModel user = await deriveTagModelFromJson(reference.id, reference.path, item.data()!);
  _memoizedTags[reference.id] = user;
  return user;
}
