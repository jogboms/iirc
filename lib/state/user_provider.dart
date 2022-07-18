// ignore_for_file: always_specify_types

import 'package:iirc/domain.dart';
import 'package:riverpod/riverpod.dart';

import 'account_provider.dart';
import 'registry_provider.dart';

final userProvider = FutureProvider<UserModel>((ref) async {
  final registry = ref.read(registryProvider);
  final users = registry.get<FetchUserUseCase>();
  final account = await ref.watch(accountProvider.future);

  return users.call(account.id);
});
