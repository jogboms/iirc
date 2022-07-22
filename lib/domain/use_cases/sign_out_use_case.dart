import 'dart:async';

import '../repositories/auth.dart';

class SignOutUseCase {
  const SignOutUseCase({required AuthRepository auth}) : _auth = auth;

  final AuthRepository _auth;

  Future<void> call() async {
    final Completer<void> completer = Completer<void>();

    late StreamSubscription<void> sub;
    sub = _auth.onAuthStateChanged.where((String? id) => id == null).listen((_) {
      completer.complete();
      sub.cancel();
    }, onError: (Object error, StackTrace st) {
      completer.completeError(error, st);
      sub.cancel();
    });

    await _auth.signOut();

    return completer.future;
  }
}
