import 'package:clock/clock.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'state_notifier_mixin.dart';

part 'calendar_state_provider.g.dart';

@riverpod
class CalendarState extends _$CalendarState with StateNotifierMixin {
  @override
  DateTime build() => clock.now();
}
