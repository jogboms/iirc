abstract class AuthException {
  const factory AuthException.unknown(Exception exception) = AuthExceptionUnknown;

  const factory AuthException.invalidEmail() = AuthExceptionInvalidEmail;

  const factory AuthException.userDisabled() = AuthExceptionUserDisabled;

  const factory AuthException.userNotFound() = AuthExceptionUserNotFound;

  const factory AuthException.tooManyRequests() = AuthExceptionTooManyRequests;

  const factory AuthException.emailAlreadyInUse() = AuthExceptionEmailAlreadyInUse;

  const factory AuthException.requiresRecentLogin() = AuthExceptionRequiresRecentLogin;
}

class AuthExceptionUnknown implements AuthException {
  const AuthExceptionUnknown(this.exception);

  final Exception exception;
}

class AuthExceptionInvalidEmail implements AuthException {
  const AuthExceptionInvalidEmail();
}

class AuthExceptionUserDisabled implements AuthException {
  const AuthExceptionUserDisabled();
}

class AuthExceptionUserNotFound implements AuthException {
  const AuthExceptionUserNotFound();
}

class AuthExceptionTooManyRequests implements AuthException {
  const AuthExceptionTooManyRequests();
}

class AuthExceptionEmailAlreadyInUse implements AuthException {
  const AuthExceptionEmailAlreadyInUse();
}

class AuthExceptionRequiresRecentLogin implements AuthException {
  const AuthExceptionRequiresRecentLogin();
}
