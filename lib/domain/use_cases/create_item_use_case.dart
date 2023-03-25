import 'dart:async';

import '../analytics/analytics.dart';
import '../analytics/analytics_event.dart';
import '../entities/create_item_data.dart';
import '../repositories/items.dart';

class CreateItemUseCase {
  const CreateItemUseCase({
    required ItemsRepository items,
    required Analytics analytics,
  })  : _items = items,
        _analytics = analytics;

  final ItemsRepository _items;
  final Analytics _analytics;

  Future<String> call(String userId, CreateItemData item) {
    unawaited(_analytics.log(AnalyticsEvent.createItem(userId)));
    return _items.create(userId, item);
  }
}
