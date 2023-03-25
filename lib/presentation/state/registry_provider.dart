import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../registry.dart';

part 'registry_provider.g.dart';

/// Container for Registry/Service locator
/// Should be overridden per [ProviderScope]
@Riverpod(dependencies: <Object>[])
Registry registry(RegistryRef ref) => throw UnimplementedError();
