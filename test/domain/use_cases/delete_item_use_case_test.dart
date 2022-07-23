import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('DeleteItemUseCase', () {
    final ItemsRepository itemsRepository = mockRepositories.items;
    final DeleteItemUseCase useCase = DeleteItemUseCase(items: itemsRepository);

    tearDown(() => reset(itemsRepository));

    test('should delete an item', () {
      when(() => itemsRepository.delete(any())).thenAnswer((_) async => true);

      expect(useCase('path'), completion(true));
    });

    test('should bubble delete errors', () {
      when(() => itemsRepository.delete(any())).thenThrow(Exception('an error'));

      expect(() => useCase('path'), throwsException);
    });
  });
}
