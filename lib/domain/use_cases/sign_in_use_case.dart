import 'dart:async';

import '../models/account.dart';
import '../repositories/auth.dart';

class SignInUseCase {
  const SignInUseCase({required AuthRepository auth}) : _auth = auth;

  final AuthRepository _auth;

  Future<AccountModel> call() async {
    final Completer<AccountModel> completer = Completer<AccountModel>();

    late StreamSubscription<void> sub;
    sub = _auth.onAuthStateChanged.where((String? id) => id != null).listen((_) {
      completer.complete(_auth.account);
      sub.cancel();
    }, onError: (Object error, StackTrace st) {
      completer.completeError(error, st);
      sub.cancel();
    });

    await _auth.signIn();

    return completer.future;
  }
}
