import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('FireUser', () {
    test('should create new instance', () {
      final FireUser user = FireUser(MockUser());
      expect(user.uid, '1');
      expect(user.email, 'email');
      expect(user.displayName, 'display name');
    });
  });
}

class MockUser extends Mock implements User {
  MockUser() {
    when(() => uid).thenReturn('1');
    when(() => email).thenReturn('email');
    when(() => displayName).thenReturn('display name');
  }
}
