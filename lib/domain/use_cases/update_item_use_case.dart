import 'dart:async';

import '../analytics/analytics.dart';
import '../analytics/analytics_event.dart';
import '../entities/update_item_data.dart';
import '../repositories/items.dart';

class UpdateItemUseCase {
  const UpdateItemUseCase({
    required ItemsRepository items,
    required Analytics analytics,
  })  : _items = items,
        _analytics = analytics;

  final ItemsRepository _items;
  final Analytics _analytics;

  Future<bool> call(UpdateItemData item) {
    unawaited(_analytics.log(AnalyticsEvent.updateItem(item.path)));
    return _items.update(item);
  }
}
