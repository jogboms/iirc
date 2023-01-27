import '../repositories/tags.dart';

class DeleteTagUseCase {
  const DeleteTagUseCase({required TagsRepository tags}) : _tags = tags;

  final TagsRepository _tags;

  Future<bool> call(String path) => _tags.delete(path);
}
