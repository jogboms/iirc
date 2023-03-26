import 'dart:async';

import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';
import 'package:registry/registry.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models.dart';
import '../../../state.dart';

part 'tag_provider.g.dart';

@Riverpod(dependencies: <Object>[registry, user])
TagProvider tag(TagRef ref) {
  final RegistryFactory di = ref.read(registryProvider).get;

  return TagProvider(
    fetchUser: () => ref.read(userProvider.future),
    createTagUseCase: di(),
    deleteTagUseCase: di(),
    updateTagUseCase: di(),
  );
}

@visibleForTesting
class TagProvider {
  const TagProvider({
    required this.fetchUser,
    required this.createTagUseCase,
    required this.updateTagUseCase,
    required this.deleteTagUseCase,
  });

  final Future<UserEntity> Function() fetchUser;
  final CreateTagUseCase createTagUseCase;
  final UpdateTagUseCase updateTagUseCase;
  final DeleteTagUseCase deleteTagUseCase;

  Future<String> create(CreateTagData data) async {
    final String userId = (await fetchUser()).id;
    return createTagUseCase(userId, data);
  }

  Future<bool> update(UpdateTagData data) async => updateTagUseCase(data);

  Future<bool> delete(TagViewModel tag) async => deleteTagUseCase(tag.path);
}
