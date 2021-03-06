import '../entities/create_tag_data.dart';
import '../entities/update_tag_data.dart';
import '../models/tag.dart';

abstract class TagsRepository {
  Future<String> create(String userId, CreateTagData tag);

  Future<bool> update(UpdateTagData tag);

  Future<bool> delete(String path);

  Stream<TagModelList> fetch(String userId);
}
