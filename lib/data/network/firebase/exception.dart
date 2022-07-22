import 'package:firebase_core/firebase_core.dart';

typedef AppFirebaseException = FirebaseException;

class AppFirebaseAuthException implements Exception {
  const AppFirebaseAuthException(this.type);

  final AppFirebaseAuthExceptionType type;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppFirebaseAuthException && runtimeType == other.runtimeType && type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() {
    return 'AppFirebaseException{type: $type}';
  }
}

enum AppFirebaseAuthExceptionType {
  canceled,
  invalidEmail,
  userDisabled,
  userNotFound,
  tooManyRequests,
  emailAlreadyInUse,
  requiresRecentLogin,
}
