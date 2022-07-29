// ignore_for_file: always_specify_types

import 'package:clock/clock.dart';
import 'package:riverpod/riverpod.dart';

final calendarStateProvider = StateProvider<DateTime>((_) => clock.now());
