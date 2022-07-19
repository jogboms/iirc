import '../entities/update_tag_data.dart';
import '../repositories/tags.dart';

class UpdateTagUseCase {
  const UpdateTagUseCase({required TagsRepository tags}) : _tags = tags;

  final TagsRepository _tags;

  Future<bool> call(UpdateTagData tag) => _tags.update(tag);
}
