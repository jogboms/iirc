import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../utils.dart';

void main() {
  group('FetchAuthStateUseCase', () {
    final AuthRepository authRepository = mockRepositories.auth;
    final FetchAuthStateUseCase useCase = FetchAuthStateUseCase(auth: authRepository);

    tearDown(() => reset(authRepository));

    test('should fetch auth', () {
      when(() => authRepository.onAuthStateChanged).thenAnswer(
        (_) => Stream<String>.value('1'),
      );

      expect(useCase(), emits('1'));
    });

    test('should bubble fetch errors', () {
      when(() => authRepository.onAuthStateChanged).thenThrow(Exception('an error'));

      expect(() => useCase(), throwsException);
    });

    test('should bubble stream errors', () {
      final Exception expectedError = Exception('an error');

      when(() => authRepository.onAuthStateChanged).thenAnswer(
        (_) => Stream<String>.error(expectedError),
      );

      expect(useCase(), emitsError(expectedError));
    });
  });
}
