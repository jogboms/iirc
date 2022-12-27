import '../entities/create_tag_data.dart';
import '../entities/tag_entity.dart';
import '../entities/update_tag_data.dart';

abstract class TagsRepository {
  Future<String> create(String userId, CreateTagData tag);

  Future<bool> update(UpdateTagData tag);

  Future<bool> delete(String path);

  Stream<TagEntityList> fetch(String userId);
}
