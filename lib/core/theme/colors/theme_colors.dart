import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:flutter/material.dart';

abstract class ThemeColors {
  Color get background;
}

class LightThemeColors extends ThemeColors {
  @override
  Color get background => StaticColors.backgroundColor;
}

class DarkThemeColors extends LightThemeColors {
  @override
  Color get background => StaticColors.backgroundColor;
}
