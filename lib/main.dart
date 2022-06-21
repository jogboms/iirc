import 'package:flutter/widgets.dart';
import 'package:intl/intl_standalone.dart';

import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await findSystemLocale();

  runApp(const App());
}
