import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('GetAccountUseCase', () {
    final AuthRepository authRepository = mockRepositories.auth;
    final GetAccountUseCase useCase = GetAccountUseCase(auth: authRepository);

    final AccountModel dummyAccount = AuthMockImpl.generateAccount();

    tearDown(() => reset(authRepository));

    test('should fetch auth', () {
      when(() => authRepository.account).thenAnswer((_) async => dummyAccount);

      expect(useCase(), completion(dummyAccount));
    });

    test('should bubble fetch errors', () {
      when(() => authRepository.account).thenThrow(Exception('an error'));

      expect(() => useCase(), throwsException);
    });
  });
}
