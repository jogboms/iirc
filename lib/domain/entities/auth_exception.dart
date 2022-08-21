abstract class AuthException {
  const factory AuthException.unknown(Exception exception) = AuthExceptionUnknown;

  const factory AuthException.canceled() = AuthExceptionCanceled;

  const factory AuthException.invalidEmail({String? email}) = AuthExceptionInvalidEmail;

  const factory AuthException.userDisabled({String? email}) = AuthExceptionUserDisabled;

  const factory AuthException.userNotFound({String? email}) = AuthExceptionUserNotFound;

  const factory AuthException.tooManyRequests({String? email}) = AuthExceptionTooManyRequests;
}

class AuthExceptionUnknown implements AuthException {
  const AuthExceptionUnknown(this.exception);

  final Exception exception;
}

class AuthExceptionCanceled implements AuthException {
  const AuthExceptionCanceled();
}

class AuthExceptionInvalidEmail implements AuthException {
  const AuthExceptionInvalidEmail({this.email});

  final String? email;
}

class AuthExceptionUserDisabled implements AuthException {
  const AuthExceptionUserDisabled({this.email});

  final String? email;
}

class AuthExceptionUserNotFound implements AuthException {
  const AuthExceptionUserNotFound({this.email});

  final String? email;
}

class AuthExceptionTooManyRequests implements AuthException {
  const AuthExceptionTooManyRequests({this.email});

  final String? email;
}
