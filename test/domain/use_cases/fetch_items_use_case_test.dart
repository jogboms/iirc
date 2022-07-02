import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('FetchItemsUseCase', () {
    final ItemsRepository itemsRepository = mockRepositories.items;
    final FetchItemsUseCase useCase = FetchItemsUseCase(items: itemsRepository);

    tearDown(() => reset(itemsRepository));

    test('should fetch items unique by tag and ordered by first', () {
      final List<ItemModel> expectedItems = List<ItemModel>.generate(3, (_) => ItemsMockImpl.generateItem());
      final Set<TagModel> uniqueTags = expectedItems.uniqueBy((ItemModel element) => element.tag);

      when(() => itemsRepository.fetch()).thenAnswer(
        (_) => Stream<List<ItemModel>>.value(expectedItems),
      );

      final Stream<List<ItemModel>> result = useCase();
      expect(result, emits(hasLength(uniqueTags.length)));
      expect(
        result,
        emits(<ItemModel>[
          for (final TagModel tag in uniqueTags)
            expectedItems.firstWhere(
              (ItemModel element) => element.tag == tag,
            ),
        ]),
      );
    });

    test('should bubble fetch errors', () {
      when(() => itemsRepository.fetch()).thenThrow(Exception('an error'));

      expect(() => useCase(), throwsException);
    });

    test('should bubble stream errors', () {
      final Exception expectedError = Exception('an error');

      when(() => itemsRepository.fetch()).thenAnswer(
        (_) => Stream<List<ItemModel>>.error(expectedError),
      );

      expect(useCase(), emitsError(expectedError));
    });
  });
}

extension UniqueByExtension<E> on Iterable<E> {
  Set<U> uniqueBy<U>(U Function(E) fn) =>
      fold(<U>{}, (Set<U> previousValue, E element) => <U>{...previousValue, fn(element)});
}
