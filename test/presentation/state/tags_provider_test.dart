import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../utils.dart';

Future<void> main() async {
  group('TagsProvider', () {
    final UserModel dummyUser = UsersMockImpl.user;

    tearDown(() {
      mockUseCases.reset();
    });

    Stream<TagViewModelList> createProviderStream() {
      final ProviderContainer container = createProviderContainer(
        overrides: <Override>[
          userProvider.overrideWithValue(AsyncData<UserModel>(dummyUser)),
        ],
      );
      addTearDown(() => container.dispose());
      return container.read(tagsProvider.stream);
    }

    test('should initialize with empty state', () {
      when(() => mockUseCases.fetchTagsUseCase.call(any())).thenAnswer((_) => const Stream<List<TagModel>>.empty());

      expect(
        createProviderStream(),
        emitsDone,
      );
    });

    test('should emit fetched tags', () async {
      final List<TagModel> expectedTags = List<TagModel>.filled(3, TagsMockImpl.generateTag());
      when(() => mockUseCases.fetchTagsUseCase.call(any()))
          .thenAnswer((_) => Stream<List<TagModel>>.value(expectedTags));

      expect(
        createProviderStream(),
        emits(expectedTags.map(TagViewModel.fromTag).toList()),
      );
    });
  });
}
