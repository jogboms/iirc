import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../../network/firebase/mocks.dart';
import '../mocks.dart';

void main() {
  group('TagsFirebaseImpl', () {
    final CloudDb db = MockCloudDb();
    final Firebase firebase = MockFirebase(db: db);
    final TagsFirebaseImpl repo = TagsFirebaseImpl(
      firebase: firebase,
      isDev: false,
      idGenerator: () => '1',
    );

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
          '1',
          const CreateTagData(
            title: 'title',
            description: 'description',
            color: 0xF,
          ),
        ),
        completion('1'),
      );

      final DynamicMap data = verify(() => reference.set(captureAny())).captured.first as DynamicMap;
      expect(data['title'], 'title');
      expect(data['description'], 'description');
      expect(data['color'], 0xF);
      expect(data['createdAt'], isA<CloudValue>());
      expect(data['updatedAt'], null);
    });

    test('should delete tag', () {
      final MapDocumentReference reference = MockMapDocumentReference();
      when(() => db.doc('path/1')).thenAnswer((_) => reference);
      when(reference.delete).thenAnswer((_) async {});

      expect(
        repo.delete('path/1'),
        completion(true),
      );
    });

    test('should update tag', () {
      final MapDocumentReference reference = MockMapDocumentReference();
      when(() => db.doc(any())).thenAnswer((_) => reference);
      when(() => reference.update(any())).thenAnswer((_) async {});

      expect(
        repo.update(
          const UpdateTagData(
            id: 'id',
            path: 'path',
            title: 'title',
            description: 'description',
            color: 0xF,
          ),
        ),
        completion(true),
      );

      final DynamicMap data = verify(() => reference.update(captureAny())).captured.first as DynamicMap;
      expect(data['title'], 'title');
      expect(data['description'], 'description');
      expect(data['color'], 0xF);
      expect(data['createdAt'], null);
      expect(data['updatedAt'], isA<CloudValue>());
    });

    test('should fetch all tags', () {
      final DateTime now = DateTime.now();
      final MapCollectionReference collection = MockCollectionReference(<DynamicMap>[
        <String, dynamic>{
          'id': '1',
          'path': 'path',
          'title': 'title',
          'description': 'description',
          'color': 0xF,
          'createdAt': CloudTimestamp.fromDate(now),
          'updatedAt': CloudTimestamp.fromDate(now),
        },
        <String, dynamic>{
          'id': '2',
          'path': 'path',
          'title': 'title',
          'description': 'description',
          'color': 0xF,
          'createdAt': CloudTimestamp.fromDate(now),
        },
      ]);
      when(() => db.collection(any())).thenAnswer((_) => collection);

      expect(
        repo.fetch('1'),
        emits(<TagEntity>[
          TagEntity(
            id: '1',
            path: 'path',
            title: 'title',
            description: 'description',
            color: 0xF,
            createdAt: now,
            updatedAt: now,
          ),
          TagEntity(
            id: '2',
            path: 'path',
            title: 'title',
            description: 'description',
            color: 0xF,
            createdAt: now,
            updatedAt: null,
          ),
        ]),
      );
    });
  });
}
