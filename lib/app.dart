import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iirc/core.dart';
import 'package:intl/intl.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (BuildContext context) => context.l10n.appName,
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        S.delegate,
        _ResetIntlUtilLocaleLocalizationDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(context.l10n.appName),
            Text(environment.name),
          ],
        ),
      ),
    );
  }
}

// TODO: intl_util generates a delegate that always sets the defaultLocale to a wrong value. This was the way to go until recently.
// This fix basically resets the defaultLocale and uses the one determined by findSystemLocale from intl found in main.dart
// See
// https://github.com/localizely/intl_utils/pull/18
// https://github.com/flutter/website/pull/3013
class _ResetIntlUtilLocaleLocalizationDelegate extends LocalizationsDelegate<void> {
  const _ResetIntlUtilLocaleLocalizationDelegate();

  @override
  Future<void> load(Locale locale) => Future<void>.sync(() => Intl.defaultLocale = null);

  @override
  bool isSupported(Locale locale) => true;

  @override
  bool shouldReload(covariant LocalizationsDelegate<void> old) => false;
}
