import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:mocktail/mocktail.dart';

import 'mocks.dart';

void main() {
  group('CloudDb', () {
    late MockFirebaseFirestore mockFirebaseFirestore;
    late CloudDb db;

    setUp(() {
      mockFirebaseFirestore = MockFirebaseFirestore();
      db = CloudDb(mockFirebaseFirestore);
    });

    test('should be able to retrieve collection', () {
      db.collection('path');

      verify(() => mockFirebaseFirestore.collection('path')).called(1);
    });

    test('should be able to retrieve document', () {
      db.doc('path');

      verify(() => mockFirebaseFirestore.doc('path')).called(1);
    });
  });
  group('CloudDbCollection', () {
    late CloudDb db;

    setUp(() {
      db = MockCloudDb();
    });

    test('should be able to fetch all items', () {
      CloudDbCollection(db, 'path').fetchAll();

      verify(() => db.collection('path')).called(1);
    });

    test('should be able to fetch one document', () {
      CloudDbCollection(db, 'path').fetchOne('1');

      verify(() => db.doc('path/1')).called(1);
    });
  });
}

class MockCloudDb extends Mock implements CloudDb {
  MockCloudDb() {
    when(() => collection(any())).thenReturn(MockMapCollectionReference());
    when(() => doc(any())).thenReturn(MockMapDocumentReference());
  }
}
