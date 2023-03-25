import 'dart:async';

import '../analytics/analytics.dart';
import '../analytics/analytics_event.dart';
import '../repositories/tags.dart';

class DeleteTagUseCase {
  const DeleteTagUseCase({
    required TagsRepository tags,
    required Analytics analytics,
  })  : _tags = tags,
        _analytics = analytics;

  final TagsRepository _tags;
  final Analytics _analytics;

  Future<bool> call(String path) {
    unawaited(_analytics.log(AnalyticsEvent.deleteTag(path)));
    return _tags.delete(path);
  }
}
