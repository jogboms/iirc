import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../../../mocks.dart';
import '../../../../utils.dart';

Future<void> main() async {
  group('TagProvider', () {
    final MockAsyncCallback<UserEntity> mockFetchUser = MockAsyncCallback<UserEntity>();
    final UserEntity dummyUser = UsersMockImpl.user;

    setUpAll(() {
      registerFallbackValue(FakeCreateTagData());
      registerFallbackValue(FakeUpdateTagData());
      registerFallbackValue(FakeTagEntity());
    });

    tearDown(() {
      reset(mockFetchUser);
      mockUseCases.reset();
    });

    TagProvider createProvider() => TagProvider(
          analytics: const NoopAnalytics(),
          fetchUser: mockFetchUser,
          createTagUseCase: mockUseCases.createTagUseCase,
          updateTagUseCase: mockUseCases.updateTagUseCase,
          deleteTagUseCase: mockUseCases.deleteTagUseCase,
        );

    test('should create new instance when read', () {
      final ProviderContainer container = createProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(tagProvider), isA<TagProvider>());
    });

    test('should create new tag for user from userProvider', () async {
      when(() => mockUseCases.createTagUseCase.call(any(), any())).thenAnswer((_) async => '1');

      final ProviderContainer container = createProviderContainer(
        overrides: <Override>[
          userProvider.overrideWithValue(AsyncData<UserEntity>(dummyUser)),
        ],
      );
      addTearDown(container.dispose);

      final TagProvider provider = container.read(tagProvider);

      final String id = await provider.create(
        const CreateTagData(
          title: 'title',
          description: 'description',
          color: 0xF,
        ),
      );

      expect(id, '1');
    });

    group('Create', () {
      test('should create new tag for user', () async {
        when(mockFetchUser.call).thenAnswer((_) async => dummyUser);
        when(() => mockUseCases.createTagUseCase.call(any(), any())).thenAnswer((_) async => '1');

        const CreateTagData createTagData = CreateTagData(title: 'title', description: 'description', color: 0xF);
        final String tagId = await createProvider().create(createTagData);

        expect(tagId, '1');
        verify(mockFetchUser.call).called(1);

        final CreateTagData resultingCreateTagData =
            verify(() => mockUseCases.createTagUseCase.call(dummyUser.id, captureAny())).captured.first
                as CreateTagData;
        expect(resultingCreateTagData, createTagData);
      });
    });

    group('Update', () {
      test('should update existing tag', () async {
        when(() => mockUseCases.updateTagUseCase.call(any())).thenAnswer((_) async => true);

        const UpdateTagData updateTagData = UpdateTagData(
          id: '1',
          path: 'path',
          title: 'title',
          description: 'description',
          color: 0xF,
        );
        await createProvider().update(updateTagData);

        final UpdateTagData resultingUpdateTagData =
            verify(() => mockUseCases.updateTagUseCase.call(captureAny())).captured.first as UpdateTagData;
        expect(resultingUpdateTagData, updateTagData);
      });
    });

    group('Delete', () {
      test('should delete existing tag', () async {
        when(() => mockUseCases.deleteTagUseCase.call(any())).thenAnswer((_) async => true);

        final TagEntity tag = TagsMockImpl.generateTag();
        await createProvider().delete(tag.asViewModel);

        final String resultingTagPath =
            verify(() => mockUseCases.deleteTagUseCase.call(captureAny())).captured.first as String;
        expect(resultingTagPath, tag.path);
      });
    });
  });
}
