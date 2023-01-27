import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('CreateItemData', () {
    test('should be equal when equal', () {
      expect(
        CreateItemData(
          tagId: '1',
          tagPath: 'path',
          description: 'description',
          date: DateTime(0),
        ),
        CreateItemData(
          tagId: '1',
          tagPath: 'path',
          description: 'description',
          date: DateTime(0),
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        CreateItemData(
          tagId: '1',
          tagPath: 'path',
          description: 'description',
          date: DateTime(0),
        ).toString(),
        'CreateItemData(description, 0000-01-01 00:00:00.000, 1, path)',
      );
    });
  });
}
