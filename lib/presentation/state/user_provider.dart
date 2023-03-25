import 'package:iirc/core.dart';
import 'package:iirc/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../registry.dart';
import 'account_provider.dart';
import 'registry_provider.dart';

part 'user_provider.g.dart';

@Riverpod(dependencies: <Object>[registry, account])
Future<UserEntity> user(UserRef ref) async {
  final Registry registry = ref.read(registryProvider);
  final AccountEntity account = await ref.watch(accountProvider.future);

  final UserEntity? user = await registry.get<FetchUserUseCase>().call(account.id);
  if (user == null) {
    throw const AppException('Failed to retrieve user details');
  }

  return user;
}
