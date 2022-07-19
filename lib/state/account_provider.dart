// ignore_for_file: always_specify_types

import 'package:iirc/domain.dart';
import 'package:riverpod/riverpod.dart';

import 'registry_provider.dart';

final accountProvider = FutureProvider<AccountModel>((ref) {
  final registry = ref.read(registryProvider);
  return registry.get<GetAccountUseCase>().call();
});
