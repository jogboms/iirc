import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('AccountModel', () {
    test('should be equal when equal', () {
      expect(
        AccountModel(
          id: nonconst('1'),
          email: 'email',
          displayName: 'display name',
        ),
        AccountModel(
          id: nonconst('1'),
          email: 'email',
          displayName: 'display name',
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        AccountModel(
          id: nonconst('1'),
          email: 'email',
          displayName: 'display name',
        ).toString(),
        'AccountModel(1, display name, email)',
      );
    });
  });
}
