import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('UpdateTagUseCase', () {
    final TagsRepository tagsRepository = mockRepositories.tags;
    final UpdateTagUseCase useCase = UpdateTagUseCase(tags: tagsRepository, analytics: const NoopAnalytics());

    final TagEntity dummyTag = TagsMockImpl.generateTag();
    final UpdateTagData dummyUpdateTagData = UpdateTagData(
      id: dummyTag.id,
      path: dummyTag.path,
      title: dummyTag.title,
      description: dummyTag.description,
      color: dummyTag.color,
    );

    setUpAll(() {
      registerFallbackValue(dummyUpdateTagData);
    });

    tearDown(() => reset(tagsRepository));

    test('should updated a tag', () {
      when(() => tagsRepository.update(any())).thenAnswer((_) async => true);

      expect(useCase(dummyUpdateTagData), completion(true));
    });

    test('should bubble update errors', () {
      when(() => tagsRepository.update(any())).thenThrow(Exception('an error'));

      expect(() => useCase(dummyUpdateTagData), throwsException);
    });
  });
}
