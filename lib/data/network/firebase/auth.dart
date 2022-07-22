import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'exception.dart';
import 'models.dart';

class Auth {
  Auth(this._auth, this._googleSignIn);

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;

  FireUser? get getUser => _mapFirebaseUserToUser(_auth.currentUser);

  Stream<FireUser?> get onAuthStateChanged => _auth.authStateChanges().map(_mapFirebaseUserToUser);

  Future<String> signInWithGoogle() async {
    try {
      GoogleSignInAccount? currentUser = _googleSignIn.currentUser;
      currentUser ??= await _googleSignIn.signInSilently();
      currentUser ??= await _googleSignIn.signIn();

      if (currentUser == null) {
        throw PlatformException(code: GoogleSignIn.kSignInCanceledError);
      }

      final GoogleSignInAuthentication auth = await currentUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
      );
      final UserCredential response = await _auth.signInWithCredential(credential);

      return response.user!.uid;
    } on FirebaseAuthException catch (e, stackTrace) {
      switch (e.code) {
        case GoogleSignIn.kSignInCanceledError:
          Error.throwWithStackTrace(
            const AppFirebaseException(AppFirebaseExceptionType.canceled),
            stackTrace,
          );
        case 'invalid-email':
          Error.throwWithStackTrace(
            const AppFirebaseException(AppFirebaseExceptionType.invalidEmail),
            stackTrace,
          );
        case 'user-disabled':
          Error.throwWithStackTrace(
            const AppFirebaseException(AppFirebaseExceptionType.userDisabled),
            stackTrace,
          );
        case 'user-not-found':
          Error.throwWithStackTrace(
            const AppFirebaseException(AppFirebaseExceptionType.userNotFound),
            stackTrace,
          );
        case 'too-many-requests':
          Error.throwWithStackTrace(
            const AppFirebaseException(AppFirebaseExceptionType.tooManyRequests),
            stackTrace,
          );
      }
      Error.throwWithStackTrace(Exception(e.toString()), stackTrace);
    }
  }

  Future<void> signOutWithGoogle() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  FireUser? _mapFirebaseUserToUser(User? _user) {
    if (_user == null) {
      return null;
    }
    return FireUser(_user);
  }
}
