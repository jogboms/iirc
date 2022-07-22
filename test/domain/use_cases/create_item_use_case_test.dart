import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('CreateItemUseCase', () {
    final ItemsRepository itemsRepository = mockRepositories.items;
    final CreateItemUseCase useCase = CreateItemUseCase(items: itemsRepository);

    final ItemModel dummyItem = ItemsMockImpl.generateItem();
    final CreateItemData dummyCreateItemData = CreateItemData(
      description: dummyItem.description,
      date: dummyItem.date,
      tag: dummyItem.tag,
    );

    setUpAll(() {
      registerFallbackValue(dummyCreateItemData);
    });

    tearDown(() => reset(itemsRepository));

    test('should create an dummyItem', () {
      when(() => itemsRepository.create(any(), any())).thenAnswer((_) async => dummyItem.id);

      expect(useCase('1', dummyCreateItemData), completion(dummyItem.id));
    });

    test('should bubble fetch errors', () {
      when(() => itemsRepository.create(any(), any())).thenThrow(Exception('an error'));

      expect(() => useCase('1', dummyCreateItemData), throwsException);
    });
  });
}
