import '../models/tag.dart';
import '../repositories/tags.dart';

class FetchTagsUseCase {
  const FetchTagsUseCase({required TagsRepository tags}) : _tags = tags;

  final TagsRepository _tags;

  Stream<TagModelList> call(String userId) => _tags.fetch(userId);
}
