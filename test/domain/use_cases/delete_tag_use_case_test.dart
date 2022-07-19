import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('DeleteTagUseCase', () {
    final TagsRepository tagsRepository = mockRepositories.tags;
    final DeleteTagUseCase useCase = DeleteTagUseCase(tags: tagsRepository);

    final TagModel dummyTag = TagsMockImpl.generateTag();

    tearDown(() => reset(tagsRepository));

    test('should delete a tag', () {
      when(() => tagsRepository.delete(any())).thenAnswer((_) async => true);

      expect(useCase(dummyTag), completion(true));
    });

    test('should bubble delete errors', () {
      when(() => tagsRepository.delete(any())).thenThrow(Exception('an error'));

      expect(() => useCase(dummyTag), throwsException);
    });
  });
}
