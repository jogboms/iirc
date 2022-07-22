import 'package:iirc/domain.dart';

import '../../network/firebase/exception.dart';
import '../../network/firebase/firebase.dart';
import '../../network/firebase/models.dart';
import '../extensions.dart';

class AuthFirebaseImpl extends AuthRepository {
  AuthFirebaseImpl({required this.firebase});

  final Firebase firebase;

  @override
  Future<AccountModel> get account async {
    final FireUser? user = firebase.auth.getUser;
    if (user == null) {
      throw const AuthException.userNotFound();
    }

    return AccountModel(email: user.email!, displayName: user.displayName, id: user.uid);
  }

  @override
  Future<String> signIn() async {
    try {
      return await firebase.auth.signInWithGoogle();
    } on AppFirebaseAuthException catch (e, stackTrace) {
      switch (e.type) {
        case AppFirebaseAuthExceptionType.invalidEmail:
          Error.throwWithStackTrace(const AuthException.invalidEmail(), stackTrace);
        case AppFirebaseAuthExceptionType.userNotFound:
          Error.throwWithStackTrace(const AuthException.userNotFound(), stackTrace);
        case AppFirebaseAuthExceptionType.tooManyRequests:
          Error.throwWithStackTrace(const AuthException.tooManyRequests(), stackTrace);
        case AppFirebaseAuthExceptionType.userDisabled:
          Error.throwWithStackTrace(const AuthException.userDisabled(), stackTrace);
        default:
          Error.throwWithStackTrace(AuthException.unknown(e), stackTrace);
      }
    }
  }

  @override
  Stream<String?> get onAuthStateChanged =>
      firebase.auth.onAuthStateChanged.map((FireUser? convert) => convert?.uid).mapErrorToAppException(true);

  @override
  Future<void> signOut() => firebase.auth.signOutWithGoogle();
}
