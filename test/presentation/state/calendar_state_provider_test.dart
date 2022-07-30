import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iirc/presentation.dart';
import 'package:riverpod/riverpod.dart';

import '../../utils.dart';

void main() {
  group('CalendarStateProvider', () {
    test('should initialize with current date', () {
      final DateTime now = DateTime(0);
      withClock(Clock(() => now), () {
        final ProviderContainer container = createProviderContainer();
        addTearDown(() => container.dispose());

        expect(
          container.read(calendarStateProvider),
          now,
        );
      });
    });
  });
}
