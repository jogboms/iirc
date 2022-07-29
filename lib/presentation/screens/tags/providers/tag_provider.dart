// ignore_for_file: always_specify_types

import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../../../state/registry_provider.dart';
import '../../../state/user_provider.dart';

final tagProvider = Provider.autoDispose<TagProvider>((ref) {
  final di = ref.read(registryProvider).get;

  return TagProvider(
    fetchUser: () => ref.read(userProvider.future),
    createTagUseCase: di(),
    deleteTagUseCase: di(),
    updateTagUseCase: di(),
  );
});

@visibleForTesting
class TagProvider {
  const TagProvider({
    required this.fetchUser,
    required this.createTagUseCase,
    required this.updateTagUseCase,
    required this.deleteTagUseCase,
  });

  final Future<UserModel> Function() fetchUser;
  final CreateTagUseCase createTagUseCase;
  final UpdateTagUseCase updateTagUseCase;
  final DeleteTagUseCase deleteTagUseCase;

  Future<String> create(CreateTagData data) async => createTagUseCase((await fetchUser()).id, data);

  Future<bool> update(UpdateTagData data) async => updateTagUseCase(data);

  Future<bool> delete(TagModel tag) async => deleteTagUseCase(tag);
}
