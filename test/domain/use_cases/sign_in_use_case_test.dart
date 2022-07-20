import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('SignInUseCase', () {
    final AuthRepository authRepository = mockRepositories.auth;
    final SignInUseCase useCase = SignInUseCase(auth: authRepository);

    tearDown(() => reset(authRepository));

    test('should sign in', () {
      when(() => authRepository.signIn()).thenAnswer((_) async => '1');

      expect(useCase(), completion('1'));
    });

    test('should bubble errors', () {
      when(() => authRepository.signIn()).thenThrow(Exception('an error'));

      expect(() => useCase(), throwsException);
    });
  });
}
