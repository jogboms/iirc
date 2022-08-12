class AnalyticsEvent {
  const AnalyticsEvent._(String name, [this.parameters]) : name = '${_eventNamePrefix}_$name';

  static const String _eventNamePrefix = 'app';

  final String name;
  final Map<String, dynamic>? parameters;

  @override
  String toString() => name + (parameters != null ? ': ${parameters?.toString()}' : '');
}
