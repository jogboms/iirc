import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('UserEntity', () {
    test('should be equal when equal', () {
      expect(
        UserEntity(
          id: nonconst('1'),
          email: 'email',
          firstName: 'first',
          lastName: 'last',
          path: 'path',
          createdAt: DateTime(0),
          lastSeenAt: DateTime(0),
        ),
        UserEntity(
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
        UserEntity(
          id: nonconst('1'),
          email: 'email',
          firstName: 'first',
          lastName: 'last',
          path: 'path',
          createdAt: DateTime(0),
          lastSeenAt: DateTime(0),
        ).toString(),
        'UserEntity(1, path, email, first, last, 0000-01-01 00:00:00.000, 0000-01-01 00:00:00.000)',
      );
    });
  });
}
