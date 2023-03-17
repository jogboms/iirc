import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../utils.dart';

Future<void> main() async {
  group('SearchTagStateProvider', () {
    late ProviderContainer container;

    final TagEntity tag = TagsMockImpl.generateTag();
    final NormalizedItemEntityList expectedItems = <NormalizedItemEntity>[
      ItemsMockImpl.generateNormalizedItem(tag: tag.copyWith(title: 'Alpha', description: 'Mango')),
      ItemsMockImpl.generateNormalizedItem(tag: tag.copyWith(title: 'Beta', description: 'Orange')),
    ];

    tearDown(mockUseCases.reset);

    AutoDisposeProvider<NormalizedItemEntityList> createProvider() {
      container = createProviderContainer();
      addTearDown(() => container.dispose());

      final AutoDisposeProvider<NormalizedItemEntityList> provider = Provider.autoDispose(
        (AutoDisposeProviderRef<Object?> ref) => filterBySearchTagQuery<NormalizedItemEntity>(
          ref,
          elements: expectedItems,
          byTitle: (NormalizedItemEntity item) => item.tag.title,
          byDescription: (NormalizedItemEntity item) => item.tag.description,
        ),
      );

      expect(container.read(provider), expectedItems);
      expect(container.read(searchTagQueryStateProvider), '');
      expect(container.read(searchTagModeStateProvider), SearchTagMode.title);

      return provider;
    }

    test('should search by title', () async {
      final AutoDisposeProvider<NormalizedItemEntityList> provider = createProvider();

      container.read(searchTagQueryStateProvider.notifier).state = 'Alpha';
      container.read(searchTagModeStateProvider.notifier).state = SearchTagMode.title;

      expect(
        container.read(provider),
        <NormalizedItemEntity>[
          expectedItems[0],
        ],
      );
    });

    test('should search by title case-insensitive', () async {
      final AutoDisposeProvider<NormalizedItemEntityList> provider = createProvider();

      container.read(searchTagQueryStateProvider.notifier).state = 'alpha';
      container.read(searchTagModeStateProvider.notifier).state = SearchTagMode.title;

      expect(
        container.read(provider),
        <NormalizedItemEntity>[
          expectedItems[0],
        ],
      );
    });

    test('should search by description', () async {
      final AutoDisposeProvider<NormalizedItemEntityList> provider = createProvider();

      container.read(searchTagQueryStateProvider.notifier).state = 'Orange';
      container.read(searchTagModeStateProvider.notifier).state = SearchTagMode.description;

      expect(
        container.read(provider),
        <NormalizedItemEntity>[
          expectedItems[1],
        ],
      );
    });

    test('should search by description case-insensitive', () async {
      final AutoDisposeProvider<NormalizedItemEntityList> provider = createProvider();

      container.read(searchTagQueryStateProvider.notifier).state = 'orange';
      container.read(searchTagModeStateProvider.notifier).state = SearchTagMode.description;

      expect(
        container.read(provider),
        <NormalizedItemEntity>[
          expectedItems[1],
        ],
      );
    });

    test('should remove edge whitespaces', () async {
      final AutoDisposeProvider<NormalizedItemEntityList> provider = createProvider();

      container.read(searchTagQueryStateProvider.notifier).state = '  orange  ';
      container.read(searchTagModeStateProvider.notifier).state = SearchTagMode.description;

      expect(
        container.read(provider),
        <NormalizedItemEntity>[
          expectedItems[1],
        ],
      );
    });

    test('should only search at specified length', () async {
      final AutoDisposeProvider<NormalizedItemEntityList> provider = createProvider();

      container.read(searchTagQueryStateProvider.notifier).state = '  o  ';
      container.read(searchTagModeStateProvider.notifier).state = SearchTagMode.description;
      await container.pump();

      expect(
        container.read(provider),
        expectedItems,
      );
    });

    test('should keep searching on query change', () async {
      final AutoDisposeProvider<NormalizedItemEntityList> provider = createProvider();
      final ProviderListener<NormalizedItemEntityList> listener = ProviderListener<NormalizedItemEntityList>();

      container.listen<NormalizedItemEntityList>(provider, listener);

      container.read(searchTagQueryStateProvider.notifier).state = 'Orange';
      container.read(searchTagModeStateProvider.notifier).state = SearchTagMode.description;
      await container.pump();

      container.read(searchTagQueryStateProvider.notifier).state = 'Mango';
      await container.pump();

      expect(
        listener.log,
        <NormalizedItemEntityList>[
          <NormalizedItemEntity>[expectedItems[1]],
          <NormalizedItemEntity>[expectedItems[0]],
        ],
      );
    });

    test('should keep searching on mode change', () async {
      final AutoDisposeProvider<NormalizedItemEntityList> provider = createProvider();
      final ProviderListener<NormalizedItemEntityList> listener = ProviderListener<NormalizedItemEntityList>();

      container.listen<NormalizedItemEntityList>(provider, listener);

      container.read(searchTagQueryStateProvider.notifier).state = 'Alpha';
      container.read(searchTagModeStateProvider.notifier).state = SearchTagMode.title;
      await container.pump();

      container.read(searchTagModeStateProvider.notifier).state = SearchTagMode.description;
      await container.pump();

      expect(
        listener.log,
        <NormalizedItemEntityList>[
          <NormalizedItemEntity>[expectedItems[0]],
          <NormalizedItemEntity>[],
        ],
      );
    });
  });
}
