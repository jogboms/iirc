import '../entities/tag_entity.dart';
import '../repositories/tags.dart';

class DeleteTagUseCase {
  const DeleteTagUseCase({required TagsRepository tags}) : _tags = tags;

  final TagsRepository _tags;

  Future<bool> call(TagEntity tag) => _tags.delete(tag.path);
}
