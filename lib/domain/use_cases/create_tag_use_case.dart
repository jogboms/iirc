import '../entities/create_tag_data.dart';
import '../repositories/tags.dart';

class CreateTagUseCase {
  const CreateTagUseCase({required TagsRepository tags}) : _tags = tags;

  final TagsRepository _tags;

  Future<String> call(String userId, CreateTagData tag) => _tags.create(userId, tag);
}
