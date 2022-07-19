import 'package:flutter/material.dart';

class TagColorScheme {
  const TagColorScheme({
    required this.brightness,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  static TagColorScheme fromHex(int value) {
    final Color backgroundColor = Color(value);
    final Brightness brightness = ThemeData.estimateBrightnessForColor(backgroundColor);
    final Color foregroundColor = brightness == Brightness.dark ? Colors.white : Colors.black;

    return TagColorScheme(
      brightness: brightness,
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
    );
  }

  final Brightness brightness;
  final Color foregroundColor;
  final Color backgroundColor;
}
