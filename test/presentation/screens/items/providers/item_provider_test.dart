import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:iirc/presentation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../../../../mocks.dart';
import '../../../../utils.dart';

Future<void> main() async {
  group('ItemProvider', () {
    final MockAsyncCallback<UserModel> mockFetchUser = MockAsyncCallback<UserModel>();
    final UserModel dummyUser = UsersMockImpl.user;

    setUpAll(() {
      registerFallbackValue(FakeCreateItemData());
      registerFallbackValue(FakeUpdateItemData());
    });

    tearDown(() {
      reset(mockFetchUser);
      mockUseCases.reset();
    });

    ItemProvider createProvider() => ItemProvider(
          analytics: const NoopAnalytics(),
          fetchUser: mockFetchUser,
          createItemUseCase: mockUseCases.createItemUseCase,
          updateItemUseCase: mockUseCases.updateItemUseCase,
          deleteItemUseCase: mockUseCases.deleteItemUseCase,
        );

    test('should create new instance when read', () {
      final ProviderContainer container = createProviderContainer();
      addTearDown(() => container.dispose());

      expect(container.read(itemProvider), isA<ItemProvider>());
    });

    test('should create new item for user from userProvider', () async {
      when(() => mockUseCases.createItemUseCase.call(any(), any())).thenAnswer((_) async => '1');

      final ProviderContainer container = createProviderContainer(
        overrides: <Override>[
          userProvider.overrideWithValue(AsyncData<UserModel>(dummyUser)),
        ],
      );
      addTearDown(() => container.dispose());

      final ItemProvider provider = container.read(itemProvider);

      final String id = await provider.create(CreateItemData(
        description: 'description',
        date: DateTime(0),
        tag: const TagModelReference(id: '1', path: 'path'),
      ));

      expect(id, '1');
    });

    group('Create', () {
      test('should create new item for user', () async {
        when(() => mockFetchUser.call()).thenAnswer((_) async => dummyUser);
        when(() => mockUseCases.createItemUseCase.call(any(), any())).thenAnswer((_) async => '1');

        final CreateItemData createItemData = CreateItemData(
          description: 'description',
          date: DateTime(0),
          tag: const TagModelReference(id: '1', path: 'path'),
        );
        final String itemId = await createProvider().create(createItemData);

        expect(itemId, '1');
        verify(() => mockFetchUser.call()).called(1);

        final CreateItemData resultingCreateItemData =
            verify(() => mockUseCases.createItemUseCase.call(dummyUser.id, captureAny())).captured.first
                as CreateItemData;
        expect(resultingCreateItemData, createItemData);
      });
    });

    group('Update', () {
      test('should update existing item', () async {
        when(() => mockUseCases.updateItemUseCase.call(any())).thenAnswer((_) async => true);

        final UpdateItemData updateItemData = UpdateItemData(
          id: '1',
          path: 'path',
          description: 'description',
          date: DateTime(0),
          tag: const TagModelReference(id: '1', path: 'path'),
        );
        await createProvider().update(updateItemData);

        final UpdateItemData resultingUpdateItemData =
            verify(() => mockUseCases.updateItemUseCase.call(captureAny())).captured.first as UpdateItemData;
        expect(resultingUpdateItemData, updateItemData);
      });
    });

    group('Delete', () {
      test('should delete existing item', () async {
        when(() => mockUseCases.deleteItemUseCase.call(any())).thenAnswer((_) async => true);

        await createProvider().delete('path');

        final String resultingPath =
            verify(() => mockUseCases.deleteItemUseCase.call(captureAny())).captured.first as String;
        expect(resultingPath, 'path');
      });
    });
  });
}
