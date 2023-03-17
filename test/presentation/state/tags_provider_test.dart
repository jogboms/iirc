import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../utils.dart';

Future<void> main() async {
  group('TagsProvider', () {
    final UserEntity dummyUser = UsersMockImpl.user;

    tearDown(mockUseCases.reset);

    Future<TagViewModelList> createProviderStream() {
      final ProviderContainer container = createProviderContainer(
        overrides: <Override>[
          userProvider.overrideWith((_) async => dummyUser),
        ],
      );
      addTearDown(container.dispose);
      return container.read(tagsProvider.future);
    }

    test('should initialize with empty state', () {
      when(() => mockUseCases.fetchTagsUseCase.call(any()))
          .thenAnswer((_) => Stream<TagEntityList>.value(<TagEntity>[]));

      expect(createProviderStream(), completes);
    });

    test('should emit fetched tags', () {
      final List<TagEntity> expectedTags = List<TagEntity>.filled(3, TagsMockImpl.generateTag());
      when(() => mockUseCases.fetchTagsUseCase.call(any()))
          .thenAnswer((_) => Stream<List<TagEntity>>.value(expectedTags));

      expect(
        createProviderStream(),
        completion(expectedTags.map(TagViewModel.fromTag).toList()),
      );
    });
  });
}
