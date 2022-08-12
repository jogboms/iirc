class AnalyticsEvent {
  const AnalyticsEvent._(String name, [this.parameters]) : name = '${_eventNamePrefix}_$name';

  static AnalyticsEvent login(String email, String uid) =>
      AnalyticsEvent._('login', <String, dynamic>{'email': email, 'user_id': uid});

  static const AnalyticsEvent logout = AnalyticsEvent._('logout');

  static AnalyticsEvent tooManyRequests(String? email) =>
      AnalyticsEvent._('too_many_requests', <String, dynamic>{'email': email});

  static AnalyticsEvent userDisabled(String? email) =>
      AnalyticsEvent._('user_disabled', <String, dynamic>{'email': email});

  static const String _eventNamePrefix = 'app';

  final String name;
  final Map<String, dynamic>? parameters;

  @override
  String toString() => name + (parameters != null ? ': ${parameters?.toString()}' : '');
}
