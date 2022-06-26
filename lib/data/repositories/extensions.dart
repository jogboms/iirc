import 'package:clock/clock.dart';
import 'package:faker/faker.dart';

extension ListExtensions<T> on List<T> {
  Map<String, T> foldToMap(String Function(T) keyBuilder) => fold(<String, T>{},
      (Map<String, T> previousValue, T element) => <String, T>{...previousValue, keyBuilder(element): element});
}

extension RandomGeneratorExtensions on RandomGenerator {
  DateTime get dateTime {
    final int year = clock.now().year;
    return DateTime(
      integer(year, min: year - 5),
      integer(12, min: 1),
      integer(29, min: 1),
      integer(23, min: 0),
      integer(59, min: 0),
    );
  }
}
