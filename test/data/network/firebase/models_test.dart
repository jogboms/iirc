import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';

import 'mocks.dart';

void main() {
  group('FireUser', () {
    test('should be equal when equal', () {
      expect(FireUser(MockUser()), FireUser(MockUser()));
      expect(FireUser(MockUser()).hashCode, FireUser(MockUser()).hashCode);
    });

    test('should create new instance', () {
      final FireUser user = FireUser(MockUser());
      expect(user.uid, '1');
      expect(user.email, 'email');
      expect(user.displayName, 'display name');
    });
  });
}
