import '../entities/tag_entity.dart';
import '../repositories/tags.dart';

class FetchTagsUseCase {
  const FetchTagsUseCase({required TagsRepository tags}) : _tags = tags;

  final TagsRepository _tags;

  Stream<TagEntityList> call(String userId) => _tags.fetch(userId);
}
