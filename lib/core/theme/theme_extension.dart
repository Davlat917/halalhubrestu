import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/theme/colors/theme_colors.dart';
import 'package:flutter/material.dart';

extension ColorExtension on BuildContext {
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  ThemeData get darkTheme => ThemeData(
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: StaticColors.primary,
      brightness: Brightness.dark, //
    ), //
  );

  ThemeData get lightTheme => ThemeData(
    scaffoldBackgroundColor: StaticColors.backgroundColor,
    appBarTheme: AppBarTheme(backgroundColor: StaticColors.white),
    brightness: Brightness.light,
    fontFamily: 'Inter',
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: StaticColors.primary,
      brightness: Brightness.light, //
    ),
  );

  ThemeColors get colors {
    return isDarkMode ? DarkThemeColors() : LightThemeColors();
  }
}
