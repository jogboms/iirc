import 'dart:async';

import '../analytics/analytics.dart';
import '../analytics/analytics_event.dart';
import '../entities/create_tag_data.dart';
import '../repositories/tags.dart';

class CreateTagUseCase {
  const CreateTagUseCase({
    required TagsRepository tags,
    required Analytics analytics,
  })  : _tags = tags,
        _analytics = analytics;

  final TagsRepository _tags;
  final Analytics _analytics;

  Future<String> call(String userId, CreateTagData tag) {
    unawaited(_analytics.log(AnalyticsEvent.createTag(userId)));
    return _tags.create(userId, tag);
  }
}
