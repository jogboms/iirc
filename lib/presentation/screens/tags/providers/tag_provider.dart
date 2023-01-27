// ignore_for_file: always_specify_types

import 'dart:async';

import 'package:iirc/domain.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

import '../../../models.dart';
import '../../../state.dart';

final tagProvider = Provider.autoDispose<TagProvider>((ref) {
  final di = ref.read(registryProvider).get;

  return TagProvider(
    analytics: di(),
    fetchUser: () => ref.read(userProvider.future),
    createTagUseCase: di(),
    deleteTagUseCase: di(),
    updateTagUseCase: di(),
  );
});

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
    final userId = (await fetchUser()).id;
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
