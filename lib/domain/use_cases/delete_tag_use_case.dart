import '../models/tag.dart';
import '../repositories/tags.dart';

class DeleteTagUseCase {
  const DeleteTagUseCase({required TagsRepository tags}) : _tags = tags;

  final TagsRepository _tags;

  Future<bool> call(TagModel tag) => _tags.delete(tag.path);
}
