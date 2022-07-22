import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('FetchTagsUseCase', () {
    final TagsRepository tagsRepository = mockRepositories.tags;
    final FetchTagsUseCase useCase = FetchTagsUseCase(tags: tagsRepository);

    tearDown(() => reset(tagsRepository));

    test('should fetch tags', () {
      final TagModelList expectedTags = TagModelList.generate(3, (_) => TagsMockImpl.generateTag());

      when(() => tagsRepository.fetch(any())).thenAnswer(
        (_) => Stream<TagModelList>.value(expectedTags),
      );

      expect(useCase('1'), emits(expectedTags));
    });

    test('should bubble fetch errors', () {
      when(() => tagsRepository.fetch(any())).thenThrow(Exception('an error'));

      expect(() => useCase('1'), throwsException);
    });

    test('should bubble stream errors', () {
      final Exception expectedError = Exception('an error');

      when(() => tagsRepository.fetch(any())).thenAnswer(
        (_) => Stream<TagModelList>.error(expectedError),
      );

      expect(useCase('1'), emitsError(expectedError));
    });
  });
}
