import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('UpdateUserData', () {
    test('should be equal when equal', () {
      expect(
        UpdateUserData(
          id: nonconst('1'),
          lastSeenAt: DateTime(0),
        ),
        UpdateUserData(
          id: nonconst('1'),
          lastSeenAt: DateTime(0),
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        UpdateUserData(
          id: nonconst('1'),
          lastSeenAt: DateTime(0),
        ).toString(),
        'UpdateUserData(1, 0000-01-01 00:00:00.000)',
      );
    });
  });
}
