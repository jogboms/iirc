// ignore_for_file: always_specify_types

import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:riverpod/riverpod.dart';

import 'account_provider.dart';
import 'registry_provider.dart';

final userProvider = FutureProvider.autoDispose<UserEntity>((ref) async {
  final registry = ref.read(registryProvider);
  final account = await ref.watch(accountProvider.future);

  final user = await registry.get<FetchUserUseCase>().call(account.id);
  if (user == null) {
    throw const AppException('Failed to retrieve user details');
  }

  return user;
});
