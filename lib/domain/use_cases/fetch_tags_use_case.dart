import '../models/tag.dart';
import '../repositories/tags.dart';

class FetchTagsUseCase {
  const FetchTagsUseCase({required TagsRepository tags}) : _tags = tags;

  final TagsRepository _tags;

  Stream<List<TagModel>> call() => _tags.fetch();
}
