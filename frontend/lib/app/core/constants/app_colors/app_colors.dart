import 'package:flutter/material.dart';

class AppColors {
  ////////////////// Ligt
  static Color lightPrimaryColor = Color(0xFF009A3F);
  static Color lightTextPrimaryColor = Color(0xFF0F1F14);
  static Color lightTSecondaryColor = Color(0xFF5F6F65);
  static Color lightBackgroundColor = Color(0xFFF5F5F5);

  ///////////////// Dark
  static Color darkPrimaryColor = Color(0xFF7DFF00);
  static Color darkTextPrimaryColor = Color(0xFFFFFFFF);
  // static Color darkTextSecondaryColor = Color
  static Color darkBackgrounColor = Color(0xFF000000);

  static ThemeData lightMode() {
    return ThemeData(
      scaffoldBackgroundColor: lightBackgroundColor,
      primaryColor: lightPrimaryColor,
      appBarTheme: AppBarTheme(backgroundColor: lightBackgroundColor),
      textTheme: TextTheme(bodyLarge: TextStyle(color: lightTextPrimaryColor)),
    );
  }

  static ThemeData darkMode() {
    return ThemeData(
      scaffoldBackgroundColor: darkBackgrounColor,
      primaryColor: darkPrimaryColor,
    );
  }
}
