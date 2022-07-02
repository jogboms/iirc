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
      final List<TagModel> expectedTags = List<TagModel>.generate(3, (_) => TagsMockImpl.generateTag());

      when(() => tagsRepository.fetch()).thenAnswer(
        (_) => Stream<List<TagModel>>.value(expectedTags),
      );

      expect(useCase(), emits(expectedTags));
    });

    test('should bubble fetch errors', () {
      when(() => tagsRepository.fetch()).thenThrow(Exception('an error'));

      expect(() => useCase(), throwsException);
    });

    test('should bubble stream errors', () {
      final Exception expectedError = Exception('an error');

      when(() => tagsRepository.fetch()).thenAnswer(
        (_) => Stream<List<TagModel>>.error(expectedError),
      );

      expect(useCase(), emitsError(expectedError));
    });
  });
}
