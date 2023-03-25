import 'dart:async';

import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../models.dart';
import '../../../registry.dart';
import '../../../state.dart';

part 'tag_provider.g.dart';

@Riverpod(dependencies: <Object>[registry, user])
TagProvider tag(TagRef ref) {
  final RegistryFactory di = ref.read(registryProvider).get;

  return TagProvider(
    analytics: di(),
    fetchUser: () => ref.read(userProvider.future),
    createTagUseCase: di(),
    deleteTagUseCase: di(),
    updateTagUseCase: di(),
  );
}

@visibleForTesting
class TagProvider {
  const TagProvider({
    required this.analytics,
    required this.fetchUser,
    required this.createTagUseCase,
    required this.updateTagUseCase,
    required this.deleteTagUseCase,
  });

  final Analytics analytics;
  final Future<UserEntity> Function() fetchUser;
  final CreateTagUseCase createTagUseCase;
  final UpdateTagUseCase updateTagUseCase;
  final DeleteTagUseCase deleteTagUseCase;

  Future<String> create(CreateTagData data) async {
    final String userId = (await fetchUser()).id;
    unawaited(analytics.log(AnalyticsEvent.createTag(userId)));
    return createTagUseCase(userId, data);
  }

  Future<bool> update(UpdateTagData data) async {
    unawaited(analytics.log(AnalyticsEvent.updateTag(data.path)));
    return updateTagUseCase(data);
  }

  Future<bool> delete(TagViewModel tag) async {
    unawaited(analytics.log(AnalyticsEvent.deleteTag(tag.path)));
    return deleteTagUseCase(tag.path);
  }
}
