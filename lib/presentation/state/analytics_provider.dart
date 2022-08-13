// ignore_for_file: always_specify_types

import 'package:iirc/domain.dart';
import 'package:riverpod/riverpod.dart';

import 'registry_provider.dart';

final analyticsProvider = Provider<Analytics>((ref) => ref.watch(registryProvider).get());
