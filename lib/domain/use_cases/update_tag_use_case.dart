import 'dart:async';

import '../analytics/analytics.dart';
import '../analytics/analytics_event.dart';
import '../entities/update_tag_data.dart';
import '../repositories/tags.dart';

class UpdateTagUseCase {
  const UpdateTagUseCase({
    required TagsRepository tags,
    required Analytics analytics,
  })  : _tags = tags,
        _analytics = analytics;

  final TagsRepository _tags;
  final Analytics _analytics;

  Future<bool> call(UpdateTagData tag) {
    unawaited(_analytics.log(AnalyticsEvent.updateTag(tag.path)));
    return _tags.update(tag);
  }
}
