import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('CreateItemData', () {
    test('should be equal when equal', () {
      expect(
        CreateItemData(
          tag: const TagReferenceEntity(id: '1', path: 'path'),
          description: 'description',
          date: DateTime(0),
        ),
        CreateItemData(
          tag: const TagReferenceEntity(id: '1', path: 'path'),
          description: 'description',
          date: DateTime(0),
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        CreateItemData(
          tag: const TagReferenceEntity(id: '1', path: 'path'),
          description: 'description',
          date: DateTime(0),
        ).toString(),
        'CreateItemData(description, 0000-01-01 00:00:00.000, TagReferenceEntity(1, path))',
      );
    });
  });
}
