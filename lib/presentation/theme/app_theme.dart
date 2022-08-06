import 'package:flutter/material.dart';

import 'app_border_radius.dart';
import 'app_colors.dart';
import 'app_style.dart';

const MaterialColor _kHintColor = Colors.grey;
const Color _kLightHintColor = Color(0xFFF5F5F5);
const Color _kBorderSideColor = Color(0x66D1D1D1);
const Color _kBorderSideErrorColor = AppColors.danger;
const double _kButtonHeight = 48.0;
const double _kIconSize = 28.0;
const String _kFontFamily = 'Metropolis';

class _AppTextTheme {
  const _AppTextTheme._();

  final TextStyle body = const TextStyle(fontSize: 14.0, fontWeight: AppFontWeight.regular);
  final TextStyle button = const TextStyle(fontSize: 15.0, fontWeight: AppFontWeight.semibold);

  final TextStyle textfield = const TextStyle(fontSize: 14.0);
  final TextStyle textfieldLabel = const TextStyle(fontSize: 14.0, color: _kHintColor);
  final TextStyle textfieldHint = const TextStyle(fontSize: 14.0, color: Color(0x666F6F6F));
  final TextStyle error = const TextStyle(fontSize: 12.0, color: _kBorderSideErrorColor);
}

class AppTheme {
  AppTheme._();

  final _AppTextTheme text = const _AppTextTheme._();

  final Color accentColor = Colors.white;
  final MaterialColor primaryColor = AppColors.primaryMaterialColor;
  final ColorSwatch<int> primarySwatch = AppColors.primarySwatch;
  final MaterialColor hintColor = _kHintColor;
  final Color errorColor = AppColors.danger;

  final Color splashBackgroundColor = const Color(0xFF100F1E);
  final BorderRadius textFieldBorderRadius = AppBorderRadius.c8;

  final List<Color> calendarViewHeaderGradient = const <Color>[Colors.purpleAccent, Colors.blueAccent];
}

ThemeData themeBuilder(ThemeData defaultTheme) {
  final Color accentColor = defaultTheme.appTheme.accentColor;
  final MaterialColor primaryColor = defaultTheme.appTheme.primaryColor;
  final ColorSwatch<int> primarySwatch = defaultTheme.appTheme.primarySwatch;

  final OutlineInputBorder _textFieldBorder = OutlineInputBorder(
    borderSide: BorderSide.none,
    borderRadius: defaultTheme.appTheme.textFieldBorderRadius,
  );
  final OutlineInputBorder _textFieldErrorBorder = _textFieldBorder.copyWith(
    borderSide: const BorderSide(color: _kBorderSideErrorColor),
  );
  final RoundedRectangleBorder _buttonShape = RoundedRectangleBorder(
    borderRadius: _textFieldBorder.borderRadius,
    side: const BorderSide(color: AppColors.primaryMaterialColor, width: 1.5),
  );
  final TextTheme textTheme = defaultTheme.typography.black
      .merge(TextTheme(
        button: defaultTheme.appTheme.text.button,
      ))
      .apply(fontFamily: _kFontFamily);

  return ThemeData(
    primaryColor: primarySwatch,
    primaryColorDark: primarySwatch[700],
    primaryColorLight: primarySwatch[100],
    iconTheme: defaultTheme.iconTheme.copyWith(size: _kIconSize),
    primaryIconTheme: defaultTheme.primaryIconTheme.copyWith(size: _kIconSize),
    textTheme: defaultTheme.textTheme.merge(textTheme),
    primaryTextTheme: defaultTheme.primaryTextTheme.merge(textTheme),
    canvasColor: accentColor,
    cardColor: accentColor,
    shadowColor: Colors.black12,
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        textStyle: MaterialStateProperty.all<TextStyle?>(textTheme.button),
        foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<OutlinedBorder>(_buttonShape),
        textStyle: MaterialStateProperty.all<TextStyle?>(textTheme.button),
        side: MaterialStateProperty.all<BorderSide?>(_buttonShape.side),
        foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
      ),
    ),
    buttonTheme: defaultTheme.buttonTheme.copyWith(
      height: _kButtonHeight,
      highlightColor: primaryColor.withOpacity(.25),
      splashColor: primaryColor.withOpacity(.25),
      shape: _buttonShape,
    ),
    colorScheme: ColorScheme.fromSwatch(
      backgroundColor: accentColor,
      primarySwatch: primaryColor,
      cardColor: accentColor,
      accentColor: accentColor,
      errorColor: defaultTheme.appTheme.errorColor,
    ),
    inputDecorationTheme: InputDecorationTheme(
      isDense: false,
      border: _textFieldBorder,
      focusedBorder: _textFieldBorder,
      enabledBorder: _textFieldBorder,
      errorBorder: _textFieldErrorBorder,
      focusedErrorBorder: _textFieldErrorBorder,
      hintStyle: defaultTheme.appTheme.text.textfieldHint,
      labelStyle: defaultTheme.appTheme.text.textfieldLabel,
      contentPadding: const EdgeInsets.all(12),
      fillColor: _kLightHintColor,
      filled: true,
      errorStyle: defaultTheme.appTheme.text.error,
    ),
    textSelectionTheme: defaultTheme.textSelectionTheme.copyWith(
      cursorColor: primarySwatch,
      selectionColor: primarySwatch[100]!.withOpacity(.25),
      selectionHandleColor: primarySwatch,
    ),
    fontFamily: _kFontFamily,
    hintColor: defaultTheme.appTheme.hintColor,
    disabledColor: defaultTheme.appTheme.hintColor,
    dividerColor: _kBorderSideColor,
  );
}

final AppTheme _appTheme = AppTheme._();

extension AppThemeThemeDataExtensions on ThemeData {
  AppTheme get appTheme => _appTheme;
}
