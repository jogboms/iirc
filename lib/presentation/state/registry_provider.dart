// ignore_for_file: always_specify_types

import 'package:riverpod/riverpod.dart';

import '../registry.dart';

/// Container for Registry/Service locator
/// Should be overridden per [ProviderScope]
final registryProvider = Provider<Registry>((_) => throw UnimplementedError());
