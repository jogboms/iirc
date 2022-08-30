import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class Crashlytics {
  const Crashlytics(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  Future<void> report(Object error, StackTrace stackTrace) async => _crashlytics.recordError(error, stackTrace);
}
