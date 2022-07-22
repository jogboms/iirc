import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('CreateTagUseCase', () {
    final TagsRepository tagsRepository = mockRepositories.tags;
    final CreateTagUseCase useCase = CreateTagUseCase(tags: tagsRepository);

    final TagModel dummyTag = TagsMockImpl.generateTag();
    final CreateTagData dummyCreateTagData = CreateTagData(
      title: dummyTag.title,
      description: dummyTag.description,
      color: dummyTag.color,
    );

    setUpAll(() {
      registerFallbackValue(dummyCreateTagData);
    });

    tearDown(() => reset(tagsRepository));

    test('should create a tag', () {
      when(() => tagsRepository.create(any(), any())).thenAnswer((_) async => dummyTag.id);

      expect(useCase('1', dummyCreateTagData), completion(dummyTag.id));
    });

    test('should bubble fetch errors', () {
      when(() => tagsRepository.create(any(), any())).thenThrow(Exception('an error'));

      expect(() => useCase('1', dummyCreateTagData), throwsException);
    });
  });
}
