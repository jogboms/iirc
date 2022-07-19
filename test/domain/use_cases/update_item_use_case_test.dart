import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('UpdateItemUseCase', () {
    final ItemsRepository itemsRepository = mockRepositories.items;
    final UpdateItemUseCase useCase = UpdateItemUseCase(items: itemsRepository);

    final ItemModel dummyItem = ItemsMockImpl.generateItem();
    final UpdateItemData dummyUpdateItemData = UpdateItemData(
      id: dummyItem.id,
      path: dummyItem.path,
      description: dummyItem.description,
      date: dummyItem.date,
      tag: dummyItem.tag,
    );

    setUpAll(() {
      registerFallbackValue(dummyUpdateItemData);
    });

    tearDown(() => reset(itemsRepository));

    test('should update an item', () {
      when(() => itemsRepository.update(any())).thenAnswer((_) async => true);

      expect(useCase(dummyUpdateItemData), completion(true));
    });

    test('should bubble update errors', () {
      when(() => itemsRepository.update(any())).thenThrow(Exception('an error'));

      expect(() => useCase(dummyUpdateItemData), throwsException);
    });
  });
}
