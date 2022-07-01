import 'package:flutter/material.dart';
import 'package:iirc/core.dart';

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
          ],
        ),
      ),
    );
  }
}
