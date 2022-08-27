import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/data.dart';
import 'package:iirc/domain.dart';
import 'package:mocktail/mocktail.dart';

import '../mocks.dart';

void main() {
  group('ItemsFirebaseImpl', () {
    final CloudDb db = MockCloudDb();
    final Firebase firebase = MockFirebase(db: db);
    final ItemsFirebaseImpl repo = ItemsFirebaseImpl(
      firebase: firebase,
      isDev: false,
      idGenerator: () => '1',
    );

    tearDown(() {
      reset(db);
      reset(firebase);
    });

    test('should create new item', () {
      final DateTime now = DateTime.now();
      final MapDocumentReference reference = MockMapDocumentReference();
      when(() => db.doc(any())).thenAnswer((_) => reference);
      when(() => reference.set(any())).thenAnswer((_) async {});

      expect(
        repo.create(
          '1',
          CreateItemData(
            description: 'description',
            date: now,
            tag: const TagModelReference(id: 'id', path: 'path'),
          ),
        ),
        completion('1'),
      );

      final DynamicMap data = verify(() => reference.set(captureAny())).captured.first as DynamicMap;
      expect(data['description'], 'description');
      expect(data['date'], CloudTimestamp.fromDate(now));
      expect(data['tag'], isA<MapDocumentReference>());
      expect(data['createdAt'], isA<CloudValue>());
      expect(data['updatedAt'], null);
    });

    test('should delete item', () {
      final MapDocumentReference reference = MockMapDocumentReference();
      when(() => db.doc('path/1')).thenAnswer((_) => reference);
      when(() => reference.delete()).thenAnswer((_) async {});

      expect(
        repo.delete('path/1'),
        completion(true),
      );
    });

    test('should update item', () {
      final DateTime now = DateTime.now();
      final MapDocumentReference reference = MockMapDocumentReference();
      when(() => db.doc(any())).thenAnswer((_) => reference);
      when(() => reference.update(any())).thenAnswer((_) async {});

      expect(
        repo.update(UpdateItemData(
          id: 'id',
          path: 'path',
          description: 'description',
          date: now,
          tag: const TagModelReference(id: 'id', path: 'path'),
        )),
        completion(true),
      );

      final DynamicMap data = verify(() => reference.update(captureAny())).captured.first as DynamicMap;
      expect(data['description'], 'description');
      expect(data['date'], CloudTimestamp.fromDate(now));
      expect(data['tag'], isA<MapDocumentReference>());
      expect(data['createdAt'], null);
      expect(data['updatedAt'], isA<CloudValue>());
    });

    test('should fetch all items', () {
      final DateTime now = DateTime.now();
      final MapDocumentReference tagReference = MockTagDocumentReference('id', 'path');
      final MapCollectionReference collection = MockCollectionReference(<DynamicMap>[
        <String, dynamic>{
          'id': '1',
          'path': 'path',
          'description': 'description',
          'tag': tagReference,
          'date': CloudTimestamp.fromDate(now),
          'createdAt': CloudTimestamp.fromDate(now),
          'updatedAt': CloudTimestamp.fromDate(now),
        },
        <String, dynamic>{
          'id': '2',
          'path': 'path',
          'description': 'description',
          'tag': tagReference,
          'date': CloudTimestamp.fromDate(now),
          'createdAt': CloudTimestamp.fromDate(now),
        },
      ]);
      when(() => db.collection(any())).thenAnswer((_) => collection);

      expect(
        repo.fetch('1'),
        emits(<ItemModel>[
          ItemModel(
            id: '1',
            path: 'path',
            description: 'description',
            tag: const TagModelReference(id: 'id', path: 'path'),
            date: now,
            createdAt: now,
            updatedAt: now,
          ),
          ItemModel(
            id: '2',
            path: 'path',
            description: 'description',
            tag: const TagModelReference(id: 'id', path: 'path'),
            date: now,
            createdAt: now,
            updatedAt: null,
          ),
        ]),
      );
    });
  });
}
