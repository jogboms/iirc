import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('TagEntity', () {
    test('should be equal when equal', () {
      expect(
        TagEntity(
          id: nonconst('1'),
          path: 'path',
          color: 0xF,
          title: 'title',
          description: 'description',
          createdAt: DateTime(0),
          updatedAt: DateTime(0),
        ),
        TagEntity(
          id: nonconst('1'),
          path: 'path',
          color: 0xF,
          title: 'title',
          description: 'description',
          createdAt: DateTime(0),
          updatedAt: DateTime(0),
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        TagEntity(
          id: nonconst('1'),
          path: 'path',
          color: 0xF,
          title: 'title',
          description: 'description',
          createdAt: DateTime(0),
          updatedAt: DateTime(0),
        ).toString(),
        'TagEntity(1, path, title, description, 15, 0000-01-01 00:00:00.000, 0000-01-01 00:00:00.000)',
      );
    });
  });
}
