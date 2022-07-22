import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class Crashlytics {
  Crashlytics(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  Future<void> report(Object error, StackTrace stackTrace) async {
    await _crashlytics.recordError(error, stackTrace);
  }
}
