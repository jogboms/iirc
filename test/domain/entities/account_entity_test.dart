import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('AccountEntity', () {
    test('should be equal when equal', () {
      expect(
        AccountEntity(
          id: nonconst('1'),
          email: 'email',
          displayName: 'display name',
        ),
        AccountEntity(
          id: nonconst('1'),
          email: 'email',
          displayName: 'display name',
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        AccountEntity(
          id: nonconst('1'),
          email: 'email',
          displayName: 'display name',
        ).toString(),
        'AccountEntity(1, display name, email)',
      );
    });
  });
}
