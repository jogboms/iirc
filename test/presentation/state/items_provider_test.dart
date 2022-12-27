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

    Stream<ItemViewModelList> createProviderStream() {
      final ProviderContainer container = createProviderContainer(
        overrides: <Override>[
          userProvider.overrideWithValue(AsyncData<UserEntity>(dummyUser)),
        ],
      );
      addTearDown(container.dispose);
      return container.read(itemsProvider.stream);
    }

    test('should initialize with empty state', () {
      when(() => mockUseCases.fetchItemsUseCase.call(any()))
          .thenAnswer((_) => const Stream<List<NormalizedItemEntity>>.empty());

      expect(
        createProviderStream(),
        emitsDone,
      );
    });

    test('should emit fetched items', () async {
      final List<NormalizedItemEntity> expectedItems =
          List<NormalizedItemEntity>.filled(3, ItemsMockImpl.generateNormalizedItem());
      when(() => mockUseCases.fetchItemsUseCase.call(any()))
          .thenAnswer((_) => Stream<List<NormalizedItemEntity>>.value(expectedItems));

      expect(
        createProviderStream(),
        emits(expectedItems.map(ItemViewModel.fromItem).toList()),
      );
    });
  });
}
