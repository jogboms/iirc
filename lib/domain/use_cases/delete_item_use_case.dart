import 'dart:async';

import '../analytics/analytics.dart';
import '../analytics/analytics_event.dart';
import '../repositories/items.dart';

class DeleteItemUseCase {
  const DeleteItemUseCase({
    required ItemsRepository items,
    required Analytics analytics,
  })  : _items = items,
        _analytics = analytics;

  final ItemsRepository _items;
  final Analytics _analytics;

  Future<bool> call(String path) {
    unawaited(_analytics.log(AnalyticsEvent.deleteItem(path)));
    return _items.delete(path);
  }
}
