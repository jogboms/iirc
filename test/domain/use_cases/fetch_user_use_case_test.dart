import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('FetchUserUseCase', () {
    final UsersRepository usersRepository = mockRepositories.users;
    final FetchUserUseCase useCase = FetchUserUseCase(users: usersRepository);

    final UserModel dummyUser = UsersMockImpl.user;

    tearDown(() => reset(usersRepository));

    test('should fetch users', () {
      when(() => usersRepository.fetch(any())).thenAnswer((_) async => dummyUser);

      expect(useCase('1'), completion(dummyUser));
    });

    test('should bubble fetch errors', () {
      when(() => usersRepository.fetch(any())).thenThrow(Exception('an error'));

      expect(() => useCase('1'), throwsException);
    });
  });
}
