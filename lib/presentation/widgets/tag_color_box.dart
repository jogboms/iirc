import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../theme/extensions.dart';
import '../utils/tag_color_scheme.dart';

class TagColorBox extends StatelessWidget {
  const TagColorBox({super.key, required this.code}) : dimension = 32;

  final int code;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    final TagColorScheme tagColorScheme = TagColorScheme.fromHex(code);

    return Material(
      shape: RoundedRectangleBorder(
        side: BorderSide(color: context.theme.appTheme.hintColor.shade700),
      ),
      color: tagColorScheme.backgroundColor,
      child: SizedBox.square(
        dimension: dimension,
        child: Icon(Icons.tag, color: tagColorScheme.foregroundColor),
      ),
    );
  }
}
