import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../utils.dart';

Future<void> main() async {
  group('SearchTagStateProvider', () {
    late ProviderContainer container;

    final TagModel tag = TagsMockImpl.generateTag();
    final List<NormalizedItemModel> expectedItems = <NormalizedItemModel>[
      ItemsMockImpl.generateNormalizedItem(tag: tag.copyWith(title: 'Alpha', description: 'Mango')),
      ItemsMockImpl.generateNormalizedItem(tag: tag.copyWith(title: 'Beta', description: 'Orange')),
    ];

    tearDown(() {
      mockUseCases.reset();
    });

    ProviderBase<List<NormalizedItemModel>> createProvider() {
      container = createProviderContainer();
      addTearDown(() => container.dispose());

      final AutoDisposeProvider<List<NormalizedItemModel>> provider = Provider.autoDispose(
        (AutoDisposeProviderRef<Object?> ref) => filterBySearchTagQuery<NormalizedItemModel>(
          ref,
          elements: expectedItems,
          byTag: (NormalizedItemModel item) => item.tag,
        ),
      );

      expect(container.read(provider), expectedItems);
      expect(container.read(searchTagQueryStateProvider), '');
      expect(container.read(searchTagModeStateProvider), SearchTagMode.title);

      return provider;
    }

    test('should search by title', () async {
      final ProviderBase<List<NormalizedItemModel>> provider = createProvider();

      container.read(searchTagQueryStateProvider.state).state = 'Alpha';
      container.read(searchTagModeStateProvider.state).state = SearchTagMode.title;
      await container.pump();

      expect(
        container.read(provider),
        <NormalizedItemModel>[
          expectedItems[0],
        ],
      );
    });

    test('should search by title case-insensitive', () async {
      final ProviderBase<List<NormalizedItemModel>> provider = createProvider();

      container.read(searchTagQueryStateProvider.state).state = 'alpha';
      container.read(searchTagModeStateProvider.state).state = SearchTagMode.title;
      await container.pump();

      expect(
        container.read(provider),
        <NormalizedItemModel>[
          expectedItems[0],
        ],
      );
    });

    test('should search by description', () async {
      final ProviderBase<List<NormalizedItemModel>> provider = createProvider();

      container.read(searchTagQueryStateProvider.state).state = 'Orange';
      container.read(searchTagModeStateProvider.state).state = SearchTagMode.description;
      await container.pump();

      expect(
        container.read(provider),
        <NormalizedItemModel>[
          expectedItems[1],
        ],
      );
    });

    test('should search by description case-insensitive', () async {
      final ProviderBase<List<NormalizedItemModel>> provider = createProvider();

      container.read(searchTagQueryStateProvider.state).state = 'orange';
      container.read(searchTagModeStateProvider.state).state = SearchTagMode.description;
      await container.pump();

      expect(
        container.read(provider),
        <NormalizedItemModel>[
          expectedItems[1],
        ],
      );
    });

    test('should remove edge whitespaces', () async {
      final ProviderBase<List<NormalizedItemModel>> provider = createProvider();

      container.read(searchTagQueryStateProvider.state).state = '  orange  ';
      container.read(searchTagModeStateProvider.state).state = SearchTagMode.description;
      await container.pump();

      expect(
        container.read(provider),
        <NormalizedItemModel>[
          expectedItems[1],
        ],
      );
    });

    test('should only search at specified length', () async {
      final ProviderBase<List<NormalizedItemModel>> provider = createProvider();

      container.read(searchTagQueryStateProvider.state).state = '  o  ';
      container.read(searchTagModeStateProvider.state).state = SearchTagMode.description;
      await container.pump();

      expect(
        container.read(provider),
        expectedItems,
      );
    });

    test('should keep searching on query change', () async {
      final ProviderBase<List<NormalizedItemModel>> provider = createProvider();

      final List<NormalizedItemModelList> log = <NormalizedItemModelList>[];

      container.listen<NormalizedItemModelList>(provider, (_, NormalizedItemModelList next) => log.add(next));

      container.read(searchTagQueryStateProvider.state).state = 'Orange';
      container.read(searchTagModeStateProvider.state).state = SearchTagMode.description;
      await container.pump();

      container.read(searchTagQueryStateProvider.state).state = 'Mango';
      await container.pump();

      expect(
        log,
        <NormalizedItemModelList>[
          <NormalizedItemModel>[expectedItems[1]],
          <NormalizedItemModel>[expectedItems[0]],
        ],
      );
    });

    test('should keep searching on mode change', () async {
      final ProviderBase<List<NormalizedItemModel>> provider = createProvider();

      final List<NormalizedItemModelList> log = <NormalizedItemModelList>[];

      container.listen<NormalizedItemModelList>(provider, (_, NormalizedItemModelList next) => log.add(next));

      container.read(searchTagQueryStateProvider.state).state = 'Alpha';
      container.read(searchTagModeStateProvider.state).state = SearchTagMode.title;
      await container.pump();

      container.read(searchTagModeStateProvider.state).state = SearchTagMode.description;
      await container.pump();

      expect(
        log,
        <NormalizedItemModelList>[
          <NormalizedItemModel>[expectedItems[0]],
          <NormalizedItemModel>[],
        ],
      );
    });
  });
}

extension on TagModel {
  TagModel copyWith({String? title, String? description}) {
    return TagModel(
      id: id,
      path: path,
      title: title ?? this.title,
      description: description ?? this.description,
      color: color,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
