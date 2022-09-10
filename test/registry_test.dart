import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/registry.dart';

void main() {
  group('Registry', () {
    group('set', () {
      test('works as expected', () {
        final Registry registry = Registry()..set(1);

        expect(registry.get<int>(), 1);
      });

      test('throws an assertion error when registered more than once', () {
        expect(
          () => Registry()
            ..set<int>(0)
            ..set<int>(1),
          throwsAssertionError,
        );
      });

      test('throws an assertion error when factory is registered more than once', () {
        expect(
          () => Registry()
            ..factory((_) => 1)
            ..factory((_) => 2),
          throwsAssertionError,
        );
      });

      test('throws an assertion error when factory is registered when normal exists', () {
        expect(
          () => Registry()
            ..set(1)
            ..factory((_) => 2),
          throwsAssertionError,
        );
      });
    });

    group('replace', () {
      test('works as expected', () {
        final Registry registry = Registry()
          ..set(1)
          ..replace(2);

        expect(registry.get<int>(), 2);
      });

      test('should replace factory methods', () {
        final Registry registry = Registry()
          ..factory((_) => 1)
          ..replace(2);

        expect(registry.get<int>(), 2);
      });
    });

    group('factory', () {
      test('works as expected', () {
        final Registry registry = Registry()
          ..set(1)
          ..factory((RegistryFactory i) => i<int>() * 1.0)
          ..factory((RegistryFactory i) => '${i<int>()} != ${i<double>()}');

        expect(registry.get<String>(), '1 != 1.0');
      });

      test('supports late initialization', () {
        final Registry registry = Registry()
          ..factory((RegistryFactory i) => '${i<int>()} != ${i<double>()}')
          ..factory((RegistryFactory i) => i<int>() * 1.0)
          ..set(1);

        expect(registry.get<String>(), '1 != 1.0');
      });
    });

    group('get', () {
      test('works as expected', () {
        final Registry registry = Registry()..set('1');

        expect(registry.get<String>(), '1');
      });

      test('works with type inference', () {
        final Registry registry = Registry()..set(1);

        int fn(int input) => input;

        expect(fn(registry.get()), 1);
      });

      test('throws an assertion error when not registered', () {
        expect(() => Registry().get<int>(), throwsArgumentError);
      });
    });
  });
}
