import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:iirc/core.dart';
import 'package:iirc/registry.dart';
import 'package:iirc/screens.dart';
import 'package:intl/intl.dart' hide TextDirection;

class App extends StatefulWidget {
  const App({
    super.key,
    required this.registry,
    this.home,
  });

  final Registry registry;
  final Widget? home;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> with SingleTickerProviderStateMixin {
  late final Environment environment = widget.registry.get();
  late final String bannerMessage = environment.name.toUpperCase();

  late final TabController menuPageTabController = TabController(
    vsync: this,
    length: MenuPageItem.values.length,
    initialIndex: MenuPageItem.defaultPage.index,
  );

  @override
  void dispose() {
    menuPageTabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MenuPageProvider(
      data: menuPageTabController,
      child: _Banner(
        key: Key(bannerMessage),
        message: bannerMessage,
        child: MaterialApp(
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
          home: widget.home ?? const OnboardingPage(),
          // home: home ?? const HomePage(),
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      alignment: Alignment.topCenter,
      children: <Widget>[
        child,
        CustomPaint(
          painter: BannerPainter(
            message: message,
            textDirection: TextDirection.ltr,
            layoutDirection: TextDirection.ltr,
            location: BannerLocation.topStart,
            color: const Color(0xFFA573E3),
          ),
        ),
      ],
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
