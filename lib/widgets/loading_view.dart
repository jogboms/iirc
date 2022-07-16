import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  static const Key loadingViewKey = Key('loadingViewKey');

  @override
  Widget build(BuildContext context) => const Center(
        key: loadingViewKey,
        child: CircularProgressIndicator(),
      );
}
