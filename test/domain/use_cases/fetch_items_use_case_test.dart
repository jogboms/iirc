import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('FetchItemsUseCase', () {
    final ItemsRepository itemsRepository = mockRepositories.items;
    final TagsRepository tagsRepository = mockRepositories.tags;
    final FetchItemsUseCase useCase = FetchItemsUseCase(items: itemsRepository, tags: tagsRepository);

    tearDown(() => reset(itemsRepository));

    test('should fetch items', () {
      final TagEntity tag = TagsMockImpl.generateTag();
      final NormalizedItemEntityList expectedItems = <NormalizedItemEntity>[
        ItemsMockImpl.generateNormalizedItem(tag: tag),
      ];

      when(() => itemsRepository.fetch(any()))
          .thenAnswer((_) => Stream<ItemEntityList>.value(expectedItems.asItemEntityList));
      when(() => tagsRepository.fetch(any())).thenAnswer((_) => Stream<TagEntityList>.value(<TagEntity>[tag]));

      expectLater(useCase('1'), emits(expectedItems));
    });

    test('should bubble fetch errors', () {
      when(() => itemsRepository.fetch(any())).thenThrow(Exception('an error'));

      expect(() => useCase('1'), throwsException);
    });

    test('should bubble stream errors', () {
      final Exception expectedError = Exception('an error');

      when(() => itemsRepository.fetch(any())).thenAnswer(
        (_) => Stream<ItemEntityList>.error(expectedError),
      );
      when(() => tagsRepository.fetch(any())).thenAnswer(
        (_) => Stream<TagEntityList>.error(expectedError),
      );

      expect(useCase('1'), emitsError(expectedError));
    });
  });
}
