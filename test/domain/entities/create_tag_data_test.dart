import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/domain.dart';

void main() {
  group('CreateTagData', () {
    test('should be equal when equal', () {
      expect(
        CreateTagData(
          title: nonconst('title'),
          description: 'description',
          color: 0xF,
        ),
        CreateTagData(
          title: nonconst('title'),
          description: 'description',
          color: 0xF,
        ),
      );
    });

    test('should serialize to string', () {
      expect(
        CreateTagData(
          title: nonconst('title'),
          description: 'description',
          color: 0xF,
        ).toString(),
        'CreateTagData(title, description, 15)',
      );
    });
  });
}
