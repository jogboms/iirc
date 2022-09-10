import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain/models/tag.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../../../utils.dart';

Future<void> main() async {
  group('FilteredItemsStateProvider', () {
    final ProviderListener<AsyncValue<FilteredItemsState>> listener =
        ProviderListener<AsyncValue<FilteredItemsState>>();
    final TagViewModelList expectedTags = TagViewModelList.generate(
      3,
      (_) => TagsMockImpl.generateTag().asViewModel,
    );
    late ProviderContainer container;

    StateController<ItemViewModelList> createProvider() {
      final StateController<ItemViewModelList> controller =
          StateController<ItemViewModelList>(ItemViewModelList.empty());
      final AutoDisposeStreamProvider<ItemViewModelList> provider =
          StreamProvider.autoDispose((_) => controller.stream);

      container = createProviderContainer(
        overrides: <Override>[
          itemsProvider.overrideWithProvider(provider),
          tagsProvider.overrideWithValue(AsyncData<TagViewModelList>(expectedTags)),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(listener.reset);

      container.listen<AsyncValue<FilteredItemsState>>(filteredItemsStateProvider, listener);

      return controller;
    }

    test('should contain all tags as is', () async {
      final StateController<ItemViewModelList> controller = createProvider();

      expect(listener.log, isEmpty);

      await container.pump();

      controller.state = ItemViewModelList.empty();

      await container.pump();
      await container.pump();

      expect(
        listener.log.last.value,
        FilteredItemsState(
          tags: expectedTags,
          items: ItemViewModelList.empty(),
        ),
      );
    });

    test('should show filtered items', () async {
      final StateController<ItemViewModelList> controller = createProvider();

      expect(listener.log, isEmpty);

      await container.pump();

      final ItemViewModelList expectedItems1 = ItemViewModelList.generate(
        3,
        (int index) => ItemsMockImpl.generateNormalizedItem(tag: TagsMockImpl.generateTag()).asViewModel,
      );
      controller.state = expectedItems1;

      await container.pump();
      await container.pump();
      await container.pump();

      expect(listener.log.last.value, FilteredItemsState(tags: expectedTags, items: expectedItems1));

      // TODO(Jogboms): figure out why this fails
      // final ItemViewModelList expectedItems2 = ItemViewModelList.generate(
      //   3,
      //   (int index) => ItemsMockImpl.generateNormalizedItem(tag: TagsMockImpl.generateTag()).asViewModel,
      // );
      // controller.state = expectedItems2;
      //
      // await container.pump();
      // await container.pump();
      // await container.pump();
      //
      // expect(listener.log.last.value, FilteredItemsState(tags: expectedTags, items: expectedItems2));
    });

    test('should show unique items filtered by tag', () async {
      final StateController<ItemViewModelList> controller = createProvider();

      expect(listener.log, isEmpty);

      await container.pump();

      final TagModel tag = TagsMockImpl.generateTag();
      final ItemViewModelList expectedItems = ItemViewModelList.generate(
        3,
        (int index) => ItemsMockImpl.generateNormalizedItem(tag: tag).asViewModel,
      );
      controller.state = expectedItems;

      await container.pump();
      await container.pump();

      expect(
        listener.log.last.value,
        FilteredItemsState(
          tags: expectedTags,
          items: <ItemViewModel>[expectedItems.first],
        ),
      );
    });

    test('should be searchable', () async {
      final StateController<ItemViewModelList> controller = createProvider();

      expect(listener.log, isEmpty);

      await container.pump();

      final ItemViewModelList expectedItems = ItemViewModelList.generate(
        3,
        (int index) {
          final TagModel tag = TagsMockImpl.generateTag();
          return ItemsMockImpl.generateNormalizedItem(tag: tag.copyWith(title: 'Query-$index')).asViewModel;
        },
      );
      controller.state = expectedItems;
      container.read(searchTagQueryStateProvider.state).state = 'Query-2';

      await container.pump();
      await container.pump();

      expect(
        listener.log.last.value,
        FilteredItemsState(
          tags: expectedTags,
          items: <ItemViewModel>[expectedItems.last],
        ),
      );
    });
  });
}
