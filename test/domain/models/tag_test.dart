import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('TagModel', () {
    test('should be equal when equal', () {
      expect(
        TagModel(
          id: nonconst('1'),
          path: 'path',
          color: 0xF,
          title: 'title',
          description: 'description',
          createdAt: DateTime(0),
          updatedAt: DateTime(0),
        ),
        TagModel(
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
        TagModel(
          id: nonconst('1'),
          path: 'path',
          color: 0xF,
          title: 'title',
          description: 'description',
          createdAt: DateTime(0),
          updatedAt: DateTime(0),
        ).toString(),
        'TagModel(1, path, title, description, 15, 0000-01-01 00:00:00.000, 0000-01-01 00:00:00.000)',
      );
    });
  });
}
