import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('UpdateItemData', () {
    test('should be equal when equal', () {
      expect(
        UpdateItemData(
          id: nonconst('1'),
          path: 'path',
          description: 'description',
          tag: const TagModelReference(id: '1', path: 'path'),
          date: DateTime(0),
        ),
        UpdateItemData(
          id: nonconst('1'),
          path: 'path',
          description: 'description',
          tag: const TagModelReference(id: '1', path: 'path'),
          date: DateTime(0),
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        UpdateItemData(
          id: nonconst('1'),
          path: 'path',
          description: 'description',
          tag: const TagModelReference(id: '1', path: 'path'),
          date: DateTime(0),
        ).toString(),
        'UpdateItemData(1, path, description, 0000-01-01 00:00:00.000, TagModelReference(1, path))',
      );
    });
  });
}
