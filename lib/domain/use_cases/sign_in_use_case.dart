import 'dart:async';

import '../entities/account_entity.dart';
import '../repositories/auth.dart';

class SignInUseCase {
  const SignInUseCase({required AuthRepository auth}) : _auth = auth;

  final AuthRepository _auth;

  Future<AccountEntity> call() async {
    final Completer<AccountEntity> completer = Completer<AccountEntity>();

    late StreamSubscription<void> sub;
    sub = _auth.onAuthStateChanged.where((String? id) => id != null).listen(
      (_) {
        completer.complete(_auth.fetch());
        sub.cancel();
      },
      onError: (Object error, StackTrace st) {
        completer.completeError(error, st);
        sub.cancel();
      },
    );

    await _auth.signIn();

    return completer.future;
  }
}
