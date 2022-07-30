import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../../../utils.dart';

Future<void> main() async {
  group('FilteredTagsStateProvider', () {
    final ProviderListener<AsyncValue<TagViewModelList>> listener = ProviderListener<AsyncValue<TagViewModelList>>();
    late ProviderContainer container;

    StateController<TagViewModelList> createProvider() {
      final StateController<TagViewModelList> controller = StateController<TagViewModelList>(TagViewModelList.empty());
      final AutoDisposeStreamProvider<TagViewModelList> provider =
          StreamProvider.autoDispose((AutoDisposeStreamProviderRef<Object?> ref) => controller.stream);

      container = createProviderContainer(
        overrides: <Override>[
          tagsProvider.overrideWithProvider(provider),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(listener.reset);

      container.listen<AsyncValue<TagViewModelList>>(filteredTagsStateProvider, listener);

      return controller;
    }

    test('should show filtered tags', () async {
      final StateController<TagViewModelList> controller = createProvider();

      expect(listener.log, isEmpty);

      final TagViewModelList expectedTags1 = TagViewModelList.generate(
        3,
        (int index) => TagsMockImpl.generateTag().asViewModel,
      );
      controller.state = expectedTags1;

      await container.pump();
      await container.pump();

      expect(listener.log.last.value, expectedTags1);

      final TagViewModelList expectedTags2 = TagViewModelList.generate(
        3,
        (int index) => TagsMockImpl.generateTag().asViewModel,
      );
      controller.state = expectedTags2;

      await container.pump();
      await container.pump();
      await container.pump();

      expect(listener.log.last.value, expectedTags2);
    });

    test('should be searchable', () async {
      final StateController<TagViewModelList> controller = createProvider();

      expect(listener.log, isEmpty);

      final TagViewModelList expectedTags = TagViewModelList.generate(
        3,
        (int index) => TagsMockImpl.generateTag().copyWith(title: 'Query-$index').asViewModel,
      );
      controller.state = expectedTags;
      container.read(searchTagQueryStateProvider.state).state = 'Query-2';

      await container.pump();
      await container.pump();

      expect(listener.log.last.value, <TagViewModel>[expectedTags.last]);
    });
  });
}
