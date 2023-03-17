import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../../../utils.dart';

Future<void> main() async {
  group('SelectedTagProvider', () {
    final ProviderListener<AsyncValue<SelectedTagState>> listener = ProviderListener<AsyncValue<SelectedTagState>>();
    const String testId = 'id';
    final TagViewModelList expectedTags = TagViewModelList.generate(
      3,
      (int index) => TagsMockImpl.generateTag(id: index == 0 ? testId : null).asViewModel,
    );
    late final ItemViewModelList expectedItems = ItemViewModelList.generate(
      3,
      (_) => ItemsMockImpl.generateNormalizedItem(tag: expectedTags.first.asTagEntity).asViewModel,
    );

    late ProviderContainer container;

    StateController<TagViewModelList> createProvider() {
      final StateController<TagViewModelList> controller = StateController<TagViewModelList>(TagViewModelList.empty());

      container = createProviderContainer(
        overrides: <Override>[
          tagsProvider.overrideWith((_) => controller.stream),
          itemsProvider.overrideWith((_) => Stream<ItemViewModelList>.value(expectedItems)),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(listener.reset);

      container.listen<AsyncValue<SelectedTagState>>(selectedTagProvider(testId), listener);

      return controller;
    }

    test('should show selected tag by id', () async {
      final StateController<TagViewModelList> controller = createProvider();

      expect(listener.log, isEmpty);

      controller.state = expectedTags;

      await container.pump();
      await container.pump();
      await container.pump();
      await container.pump();

      expect(
        listener.log.last.value,
        SelectedTagState(tag: expectedTags.first, items: expectedItems),
      );
    });

    test('should show updated selected tag by id when tags changes', () async {
      final StateController<TagViewModelList> controller = createProvider();

      expect(listener.log, isEmpty);

      final TagViewModel expectedTag = expectedTags[0].copyWith(description: 'description');
      controller.state = <TagViewModel>[expectedTag, ...expectedTags.sublist(1)];

      await container.pump();
      await container.pump();
      await container.pump();
      await container.pump();

      expect(
        listener.log.last.value,
        SelectedTagState(tag: expectedTag, items: expectedItems),
      );
    });

    // TODO(Jogboms): implement test case.
    test('should show updated selected tag by id when items changes', () async {}, skip: true);
  });
}

extension on TagViewModel {
  TagViewModel copyWith({String? description}) {
    return TagViewModel(
      id: id,
      path: path,
      description: description ?? this.description,
      createdAt: createdAt,
      color: color,
      title: title,
      updatedAt: updatedAt,
      brightness: brightness,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
  }
}
