import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('CreateUserUseCase', () {
    final UsersRepository usersRepository = mockRepositories.users;
    final CreateUserUseCase useCase = CreateUserUseCase(users: usersRepository);

    final AccountModel dummyAccountModel = AuthMockImpl.generateAccount();

    setUpAll(() {
      registerFallbackValue(dummyAccountModel);
    });

    tearDown(() => reset(usersRepository));

    test('should create a user', () {
      when(() => usersRepository.create(any())).thenAnswer((_) async => dummyAccountModel.id);

      expect(useCase(dummyAccountModel), completion(dummyAccountModel.id));
    });

    test('should bubble create errors', () {
      when(() => usersRepository.create(any())).thenThrow(Exception('an error'));

      expect(() => useCase(dummyAccountModel), throwsException);
    });
  });
}
