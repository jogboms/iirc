import 'package:iirc/domain.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../registry.dart';
import 'registry_provider.dart';

part 'account_provider.g.dart';

@Riverpod(dependencies: <Object>[registry])
Future<AccountEntity> account(AccountRef ref) async {
  final Registry registry = ref.read(registryProvider);
  return registry.get<GetAccountUseCase>().call();
}
