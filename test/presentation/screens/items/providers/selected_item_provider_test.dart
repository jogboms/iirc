import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../../../utils.dart';

Future<void> main() async {
  group('SelectedItemProvider', () {
    final ProviderListener<AsyncValue<ItemViewModel>> listener = ProviderListener<AsyncValue<ItemViewModel>>();
    const String testId = 'id';
    final List<ItemViewModel> expectedItems = ItemViewModelList.generate(
      3,
      (int index) => ItemsMockImpl.generateNormalizedItem(id: index == 0 ? testId : null).asViewModel,
    );
    late ProviderContainer container;

    StateController<ItemViewModelList> createProvider() {
      final StateController<ItemViewModelList> controller =
          StateController<ItemViewModelList>(ItemViewModelList.empty());

      container = createProviderContainer(
        overrides: <Override>[
          itemsProvider.overrideWith((_) => controller.stream),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(listener.reset);

      container.listen<AsyncValue<ItemViewModel>>(selectedItemProvider(testId), listener);

      return controller;
    }

    test('should show selected item by id', () async {
      final StateController<ItemViewModelList> controller = createProvider();

      expect(listener.log, isEmpty);

      controller.state = expectedItems;

      await container.pump();
      await container.pump();

      expect(listener.log.last.value, expectedItems.first);
    });

    test('should show updated selected item by id when items changes', () async {
      final StateController<ItemViewModelList> controller = createProvider();

      expect(listener.log, isEmpty);

      final ItemViewModel expectedItem = expectedItems[0].copyWith(description: 'description');
      controller.state = <ItemViewModel>[expectedItem, ...expectedItems.sublist(1)];

      await container.pump();
      await container.pump();

      expect(listener.log.last.value, expectedItem);
    });
  });
}

extension on ItemViewModel {
  ItemViewModel copyWith({String? description}) {
    return ItemViewModel(
      id: id,
      path: path,
      description: description ?? this.description,
      date: date,
      tag: tag,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
