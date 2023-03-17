import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../utils.dart';

Future<void> main() async {
  group('ItemsProvider', () {
    final UserEntity dummyUser = UsersMockImpl.user;

    tearDown(mockUseCases.reset);

    Future<ItemViewModelList> createProviderStream() {
      final ProviderContainer container = createProviderContainer(
        overrides: <Override>[
          userProvider.overrideWith((_) async => dummyUser),
        ],
      );
      addTearDown(container.dispose);
      return container.read(itemsProvider.future);
    }

    test('should initialize with empty state', () {
      when(() => mockUseCases.fetchItemsUseCase.call(any()))
          .thenAnswer((_) => Stream<NormalizedItemEntityList>.value(<NormalizedItemEntity>[]));

      expect(createProviderStream(), completes);
    });

    test('should emit fetched items', () {
      final NormalizedItemEntityList expectedItems =
          List<NormalizedItemEntity>.filled(3, ItemsMockImpl.generateNormalizedItem());
      when(() => mockUseCases.fetchItemsUseCase.call(any()))
          .thenAnswer((_) => Stream<List<NormalizedItemEntity>>.value(expectedItems));

      expect(
        createProviderStream(),
        completion(expectedItems.map(ItemViewModel.fromItem).toList()),
      );
    });
  });
}
