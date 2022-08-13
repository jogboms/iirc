class AnalyticsEvent {
  const AnalyticsEvent._(String name, [this.parameters]) : name = '${_eventNamePrefix}_$name';

  static AnalyticsEvent login(String email, String uid) =>
      AnalyticsEvent._('login', <String, dynamic>{'email': email, 'user_id': uid});

  static const AnalyticsEvent logout = AnalyticsEvent._('logout');

  static AnalyticsEvent tooManyRequests(String? email) =>
      AnalyticsEvent._('too_many_requests', <String, dynamic>{'email': email});

  static AnalyticsEvent userDisabled(String? email) =>
      AnalyticsEvent._('user_disabled', <String, dynamic>{'email': email});

  static AnalyticsEvent itemClick(String action) => AnalyticsEvent._('item_click', <String, dynamic>{'action': action});

  static AnalyticsEvent buttonClick(String action) =>
      AnalyticsEvent._('button_click', <String, dynamic>{'action': action});

  static AnalyticsEvent createItem(String userId) =>
      AnalyticsEvent._('create_item', <String, dynamic>{'user_id': userId});

  static AnalyticsEvent updateItem(String path) => AnalyticsEvent._('update_item', <String, dynamic>{'path': path});

  static AnalyticsEvent deleteItem(String path) => AnalyticsEvent._('delete_item', <String, dynamic>{'path': path});

  static AnalyticsEvent createTag(String userId) =>
      AnalyticsEvent._('create_tag', <String, dynamic>{'user_id': userId});

  static AnalyticsEvent updateTag(String path) => AnalyticsEvent._('update_tag', <String, dynamic>{'path': path});

  static AnalyticsEvent deleteTag(String path) => AnalyticsEvent._('delete_tag', <String, dynamic>{'path': path});

  static const String _eventNamePrefix = 'app';

  final String name;
  final Map<String, dynamic>? parameters;

  @override
  String toString() => name + (parameters != null ? ': ${parameters?.toString()}' : '');
}
