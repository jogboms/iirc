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
      final TagModel tag = TagsMockImpl.generateTag();
      final NormalizedItemModelList expectedItems = <NormalizedItemModel>[
        ItemsMockImpl.generateNormalizedItem(tag: tag)
      ];

      when(() => itemsRepository.fetch(any()))
          .thenAnswer((_) => Stream<ItemModelList>.value(expectedItems.asItemModelList));
      when(() => tagsRepository.fetch(any())).thenAnswer((_) => Stream<TagModelList>.value(<TagModel>[tag]));

      expectLater(useCase('1'), emits(expectedItems));
    });

    test('should bubble fetch errors', () {
      when(() => itemsRepository.fetch(any())).thenThrow(Exception('an error'));

      expect(() => useCase('1'), throwsException);
    });

    test('should bubble stream errors', () {
      final Exception expectedError = Exception('an error');

      when(() => itemsRepository.fetch(any())).thenAnswer(
        (_) => Stream<ItemModelList>.error(expectedError),
      );
      when(() => tagsRepository.fetch(any())).thenAnswer(
        (_) => Stream<TagModelList>.error(expectedError),
      );

      expect(useCase('1'), emitsError(expectedError));
    });
  });
}
