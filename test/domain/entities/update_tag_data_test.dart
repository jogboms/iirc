import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('UpdateTagData', () {
    test('should be equal when equal', () {
      expect(
        UpdateTagData(
          id: nonconst('1'),
          path: 'path',
          title: 'title',
          description: 'description',
          color: 0xF,
        ),
        UpdateTagData(
          id: nonconst('1'),
          path: 'path',
          title: 'title',
          description: 'description',
          color: 0xF,
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        UpdateTagData(
          id: nonconst('1'),
          path: 'path',
          title: 'title',
          description: 'description',
          color: 0xF,
        ).toString(),
        'UpdateTagData(1, path, title, description, 15)',
      );
    });
  });
}
