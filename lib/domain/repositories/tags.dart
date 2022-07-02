import '../entities/create_tag_data.dart';
import '../entities/update_tag_data.dart';
import '../models/tag.dart';

abstract class TagsRepository {
  Future<TagModel> create(String userId, CreateTagData tag);

  Future<bool> update(UpdateTagData tag);

  Stream<TagModelList> fetch();
}
