import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';

void main() {
  group('AppFirebaseAuthException', () {
    test('should be equal when equal', () {
      expect(
        AppFirebaseAuthException(AppFirebaseAuthExceptionType.failed, email: nonconst(null)),
        AppFirebaseAuthException(AppFirebaseAuthExceptionType.failed, email: nonconst(null)),
      );
      expect(
        AppFirebaseAuthException(AppFirebaseAuthExceptionType.failed, email: nonconst('email')),
        AppFirebaseAuthException(AppFirebaseAuthExceptionType.failed, email: nonconst('email')),
      );
      expect(
        AppFirebaseAuthException(AppFirebaseAuthExceptionType.failed, email: nonconst(null)).hashCode,
        AppFirebaseAuthException(AppFirebaseAuthExceptionType.failed, email: nonconst(null)).hashCode,
      );
    });

    test('should serialize to string', () {
      expect(
        AppFirebaseAuthException(
          AppFirebaseAuthExceptionType.failed,
          email: nonconst('email'),
        ).toString(),
        'AppFirebaseAuthException{type: AppFirebaseAuthExceptionType.failed, email: email}',
      );
    });
  });
}
