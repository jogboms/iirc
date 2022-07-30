import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain/models/tag.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../../../utils.dart';

Future<void> main() async {
  group('FilteredItemsStateProvider', () {
    final ProviderListener<AsyncValue<ItemViewModelList>> listener = ProviderListener<AsyncValue<ItemViewModelList>>();
    late ProviderContainer container;

    StateController<ItemViewModelList> createProvider() {
      final StateController<ItemViewModelList> controller =
          StateController<ItemViewModelList>(ItemViewModelList.empty());
      final AutoDisposeStreamProvider<ItemViewModelList> provider =
          StreamProvider.autoDispose((AutoDisposeStreamProviderRef<Object?> ref) => controller.stream);

      container = createProviderContainer(
        overrides: <Override>[
          itemsProvider.overrideWithProvider(provider),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(listener.reset);

      container.listen<AsyncValue<ItemViewModelList>>(filteredItemsStateProvider, listener);

      return controller;
    }

    test('should show filtered items', () async {
      final StateController<ItemViewModelList> controller = createProvider();

      expect(listener.log, isEmpty);

      final ItemViewModelList expectedItems1 = ItemViewModelList.generate(
        3,
        (int index) => ItemsMockImpl.generateNormalizedItem(tag: TagsMockImpl.generateTag()).asViewModel,
      );
      controller.state = expectedItems1;

      await container.pump();
      await container.pump();

      expect(listener.log.last.value, expectedItems1);

      final ItemViewModelList expectedItems2 = ItemViewModelList.generate(
        3,
        (int index) => ItemsMockImpl.generateNormalizedItem(tag: TagsMockImpl.generateTag()).asViewModel,
      );
      controller.state = expectedItems2;

      await container.pump();
      await container.pump();
      await container.pump();

      expect(listener.log.last.value, expectedItems2);
    });

    test('should show unique items filtered by tag', () async {
      final StateController<ItemViewModelList> controller = createProvider();

      expect(listener.log, isEmpty);

      final TagModel tag = TagsMockImpl.generateTag();
      final ItemViewModelList expectedItems = ItemViewModelList.generate(
        3,
        (int index) => ItemsMockImpl.generateNormalizedItem(tag: tag).asViewModel,
      );
      controller.state = expectedItems;

      await container.pump();
      await container.pump();

      expect(listener.log.last.value, <ItemViewModel>[expectedItems.first]);
    });
  });
}
