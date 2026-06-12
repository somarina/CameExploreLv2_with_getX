import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  //   ============ Light ============
  static const Color lightPrimaryColor = Color(0xFF009A3F);
  static const Color lightTextColor = Color(0xFF000000);
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color lightButtonColor = Color(0xFFE7000B);
  //   ============ Dark ============
  static Color darkPrimaryColor = Color(0xFF009A3F);
  static Color darkTextColor = Color(0xFFFFFFFF);
  static Color darkBackgrounColor = Color(0xFF000000);
  static Color darkButtonColor = Color(0xFFE7000B);

  // variable
  var isDark = true.obs;
  final themeMode = ThemeMode.system.obs;

  static ThemeData lightMode() {
    return ThemeData(
      scaffoldBackgroundColor: lightBackgroundColor,
      primaryColor: lightPrimaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lightBackgroundColor,
        primary: lightPrimaryColor,
        secondary: lightTextColor,
        tertiary: lightButtonColor,
      ),
    );
  }

  static ThemeData darkMode() {
    return ThemeData(
      scaffoldBackgroundColor: darkBackgrounColor,
      primaryColor: darkPrimaryColor,
      colorScheme: ColorScheme.fromSeed(
             seedColor: darkBackgrounColor,
        primary: darkPrimaryColor,
        secondary: darkTextColor,
        tertiary: darkButtonColor,
      ),
    );
  }
}
