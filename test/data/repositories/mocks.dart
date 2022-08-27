// ignore_for_file: subtype_of_sealed_class

import 'package:iirc/data.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebase extends Mock implements Firebase {
  MockFirebase({CloudDb? db}) {
    if (db != null) {
      when(() => this.db).thenReturn(db);
    }
  }
}

class MockCloudDb extends Mock implements CloudDb {}

class MockCollectionReference extends Mock implements MapCollectionReference {
  MockCollectionReference(List<DynamicMap> items) {
    final MapQuerySnapshot querySnapshot = MockQuerySnapshot();

    when(() => orderBy(any(), descending: any(named: 'descending'))).thenReturn(this);
    when(() => snapshots()).thenAnswer((_) => Stream<MapQuerySnapshot>.value(querySnapshot));

    final List<MapQueryDocumentSnapshot> docs = <MapQueryDocumentSnapshot>[];
    for (final DynamicMap data in items) {
      final MapQueryDocumentSnapshot snapshot = MockQueryDocumentSnapshot();
      when(() => snapshot.id).thenAnswer((_) => data['id'] as String);
      when(() => snapshot.data()).thenAnswer((_) => data);

      final MapDocumentReference reference = MockMapDocumentReference();
      when(() => snapshot.reference).thenReturn(reference);
      when(() => reference.path).thenReturn(data['path'] as String);

      docs.add(snapshot);
    }

    when(() => querySnapshot.docs).thenAnswer((_) => docs);
  }
}

class MockQuerySnapshot extends Mock implements MapQuerySnapshot {}

class MockQueryDocumentSnapshot extends Mock implements MapQueryDocumentSnapshot {}

class MockMapDocumentReference extends Mock implements MapDocumentReference {}

class MockTagDocumentReference extends MockMapDocumentReference {
  MockTagDocumentReference(String id, String path) {
    when(() => this.id).thenReturn(id);
    when(() => this.path).thenReturn(path);
  }
}
