import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('ItemModel', () {
    test('should be equal when equal', () {
      expect(
        ItemModel(
          id: nonconst('1'),
          path: 'path',
          description: 'description',
          tag: const TagModelReference(id: '1', path: 'path'),
          date: DateTime(0),
          createdAt: DateTime(0),
          updatedAt: DateTime(0),
        ),
        ItemModel(
          id: nonconst('1'),
          path: 'path',
          description: 'description',
          tag: const TagModelReference(id: '1', path: 'path'),
          date: DateTime(0),
          createdAt: DateTime(0),
          updatedAt: DateTime(0),
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        ItemModel(
          id: nonconst('1'),
          path: 'path',
          description: 'description',
          tag: const TagModelReference(id: '1', path: 'path'),
          date: DateTime(0),
          createdAt: DateTime(0),
          updatedAt: DateTime(0),
        ).toString(),
        'BaseItemModel<TagModelReference>(1, path, description, 0000-01-01 00:00:00.000, TagModelReference(1, path), 0000-01-01 00:00:00.000, 0000-01-01 00:00:00.000)',
      );
    });
  });
}
