class AppFirebaseException implements Exception {
  const AppFirebaseException(this.type);

  final AppFirebaseExceptionType type;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AppFirebaseException && runtimeType == other.runtimeType && type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() {
    return 'AppFirebaseException{type: $type}';
  }
}

enum AppFirebaseExceptionType {
  canceled,
  invalidEmail,
  userDisabled,
  userNotFound,
  tooManyRequests,
  emailAlreadyInUse,
  requiresRecentLogin,
}
