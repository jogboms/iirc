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

    test('should fetch items', () {
      final List<ItemModel> expectedItems = List<ItemModel>.generate(3, (_) => ItemsMockImpl.generateItem());

      when(() => itemsRepository.fetch()).thenAnswer(
        (_) => Stream<List<ItemModel>>.value(expectedItems),
      );

      expect(useCase(), emits(expectedItems));
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
