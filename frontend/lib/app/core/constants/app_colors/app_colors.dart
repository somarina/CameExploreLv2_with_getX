import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  //   ============ Light ============
  static const Color lightPrimaryColor = Color(0xFF009A3F);
  static const Color lightTextColor = Color(0xFF000000);
  static const Color lightBackgroundColor = Color(0xFFF5F5F5);
  static const Color lightButtonColor = Color(0xFFE7000B);

  static Color lightContainerColor = Color(0xFFFFFFFf);
  //   ============ Dark ============
  static Color darkPrimaryColor = Color(0xFF009A3F);
  static Color darkTextColor = Color(0xFFFFFFFF);
  static Color darkBackgrounColor = Color(0xFF000000);
  static Color darkButtonColor = Color(0xFFE7000B);

  static Color darkContainerColor = Color(0xFF1a1a1a);
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
        primaryContainer: lightContainerColor,
        onSurface: Colors.black,
      ),
      textTheme: TextTheme(titleSmall: TextStyle(color: Color(0xff5F6F65))),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: lightContainerColor,
        headerBackgroundColor: lightPrimaryColor,
        headerForegroundColor: Colors.white,
        todayForegroundColor: WidgetStatePropertyAll(lightPrimaryColor),
        todayBackgroundColor: WidgetStatePropertyAll(Colors.white),
        todayBorder: BorderSide(color: lightPrimaryColor),

        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          if (states.contains(WidgetState.disabled)) {
            return Colors.black38;
          }
          return Colors.black;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return lightPrimaryColor;
          }
          return null;
        }),

        yearForegroundColor: WidgetStatePropertyAll(Colors.black),
        weekdayStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
        // Month-Year dropdown (June 2026)
        subHeaderForegroundColor: Colors.black,

        // Cancel / OK buttons
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: Colors.black),
        confirmButtonStyle: TextButton.styleFrom(
          foregroundColor: lightPrimaryColor,
        ),

        rangeSelectionBackgroundColor: lightPrimaryColor.withValues(
          alpha: 0.15,
        ),
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
        primaryContainer: darkContainerColor,
        onSurface: Colors.white,
      ),
      textTheme: TextTheme(titleSmall: TextStyle(color: Color(0xffe3e3e3))),

      datePickerTheme: DatePickerThemeData(
        backgroundColor: darkContainerColor,
        headerBackgroundColor: darkPrimaryColor,
        headerForegroundColor: Colors.white,
        rangePickerBackgroundColor: darkContainerColor,
        rangePickerHeaderForegroundColor: Colors.white,
        rangePickerSurfaceTintColor: Colors.white,

        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          if (states.contains(WidgetState.disabled)) {
            return Colors.white38;
          }
          return Colors.white;
        }),

        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return darkPrimaryColor;
          }
          return null;
        }),

        rangeSelectionBackgroundColor: darkPrimaryColor.withValues(alpha: 0.2),

        rangeSelectionOverlayColor: WidgetStatePropertyAll(Colors.transparent),

        todayForegroundColor: WidgetStatePropertyAll(Colors.white),
        todayBorder: BorderSide(color: darkPrimaryColor),

        weekdayStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),

        subHeaderForegroundColor: Colors.white,
        yearForegroundColor: WidgetStatePropertyAll(Colors.white),
        cancelButtonStyle: TextButton.styleFrom(foregroundColor: Colors.white),
        confirmButtonStyle: TextButton.styleFrom(foregroundColor: Colors.green),
      ),
    );
  }
}
