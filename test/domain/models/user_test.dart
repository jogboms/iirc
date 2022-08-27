import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('UserModel', () {
    test('should be equal when equal', () {
      expect(
        UserModel(
          id: nonconst('1'),
          email: 'email',
          firstName: 'first',
          lastName: 'last',
          path: 'path',
          createdAt: DateTime(0),
          lastSeenAt: DateTime(0),
        ),
        UserModel(
          id: nonconst('1'),
          email: 'email',
          firstName: 'first',
          lastName: 'last',
          path: 'path',
          createdAt: DateTime(0),
          lastSeenAt: DateTime(0),
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        UserModel(
          id: nonconst('1'),
          email: 'email',
          firstName: 'first',
          lastName: 'last',
          path: 'path',
          createdAt: DateTime(0),
          lastSeenAt: DateTime(0),
        ).toString(),
        'UserModel(1, path, email, first, last, 0000-01-01 00:00:00.000, 0000-01-01 00:00:00.000)',
      );
    });
  });
}
