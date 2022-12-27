import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../network/firebase/mocks.dart';
import '../mocks.dart';

void main() {
  group('UsersFirebaseImpl', () {
    final CloudDb db = MockCloudDb();
    final Firebase firebase = MockFirebase(db: db);
    final UsersFirebaseImpl repo = UsersFirebaseImpl(firebase: firebase);

    tearDown(() {
      reset(db);
      reset(firebase);
    });

    test('should create new tag', () {
      final MapDocumentReference reference = MockMapDocumentReference();
      when(() => db.doc(any())).thenAnswer((_) => reference);
      when(() => reference.set(any())).thenAnswer((_) async {});

      expect(
        repo.create(
          const AccountEntity(
            id: '1',
            displayName: 'display name',
            email: 'email',
          ),
        ),
        completion('1'),
      );

      final DynamicMap data = verify(() => reference.set(captureAny())).captured.first as DynamicMap;
      expect(data['email'], 'email');
      expect(data['firstName'], 'display');
      expect(data['lastName'], 'name');
      expect(data['createdAt'], isA<CloudValue>());
      expect(data['lastSeenAt'], isA<CloudValue>());
    });

    test('should update tag', () {
      final DateTime now = DateTime.now();
      final MapDocumentReference reference = MockMapDocumentReference();
      when(() => db.doc(any())).thenAnswer((_) => reference);
      when(() => reference.update(any())).thenAnswer((_) async {});

      expect(
        repo.update(
          UpdateUserData(
            id: 'id',
            lastSeenAt: now,
          ),
        ),
        completion(true),
      );

      final DynamicMap data = verify(() => reference.update(captureAny())).captured.first as DynamicMap;
      expect(data['email'], null);
      expect(data['firstName'], null);
      expect(data['lastName'], null);
      expect(data['createdAt'], null);
      expect(data['lastSeenAt'], isA<CloudTimestamp>());
    });

    test('should fetch user data when it does not exist', () {
      final MapDocumentReference doc = MockUserDocumentReference();
      when(() => db.doc(any())).thenAnswer((_) => doc);

      expect(
        repo.fetch('1'),
        completion(null),
      );
    });

    group('should fetch user data when it exists', () {
      final DateTime now = DateTime.now();

      test('and with missing names', () {
        final MapDocumentReference doc = MockUserDocumentReference(<String, dynamic>{
          'id': '1',
          'path': 'path',
          'email': 'email',
          'lastSeenAt': CloudTimestamp.fromDate(now),
          'createdAt': CloudTimestamp.fromDate(now),
        });
        when(() => db.doc(any())).thenAnswer((_) => doc);

        expect(
          repo.fetch('1'),
          completion(
            UserEntity(
              id: '1',
              path: 'path',
              firstName: '',
              lastName: '',
              email: 'email',
              createdAt: now,
              lastSeenAt: now,
            ),
          ),
        );
      });

      test('with available names', () {
        final MapDocumentReference doc = MockUserDocumentReference(<String, dynamic>{
          'id': '1',
          'path': 'path',
          'firstName': 'first',
          'lastName': 'last',
          'email': 'email',
          'lastSeenAt': CloudTimestamp.fromDate(now),
          'createdAt': CloudTimestamp.fromDate(now),
        });
        when(() => db.doc(any())).thenAnswer((_) => doc);

        expect(
          repo.fetch('1'),
          completion(
            UserEntity(
              id: '1',
              path: 'path',
              firstName: 'first',
              lastName: 'last',
              email: 'email',
              createdAt: now,
              lastSeenAt: now,
            ),
          ),
        );
      });
    });
  });
}
