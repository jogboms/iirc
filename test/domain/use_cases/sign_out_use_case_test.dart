import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('SignOutUseCase', () {
    final AuthRepository authRepository = mockRepositories.auth;
    final SignOutUseCase useCase = SignOutUseCase(auth: authRepository);

    tearDown(() => reset(authRepository));

    test('should sign in', () {
      when(() => authRepository.signOut()).thenAnswer((_) async {});

      expect(useCase(), completes);
    });

    test('should bubble errors', () {
      when(() => authRepository.signOut()).thenThrow(Exception('an error'));

      expect(() => useCase(), throwsException);
    });
  });
}
