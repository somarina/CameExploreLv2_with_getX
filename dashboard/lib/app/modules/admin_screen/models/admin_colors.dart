import 'package:flutter/material.dart';

/// Shared style constants for the Admin Dashboard UI.
/// Kept in one place so the whole dashboard stays visually consistent.
class AdminColors {
  AdminColors._();

  // Primary colors
  static const primary = Color(0xFF2F6FED);
  static const primaryLight = Color(0xFFEAF2FF);
  static const primaryDark = Color(0xFF1E3F8E);

  // Status colors
  static const green = Color(0xFF10B981);
  static const greenLight = Color(0xFFE8F9F1);
  static const greenDark = Color(0xFF1F3A34);

  static const amber = Color(0xFFF59E0B);
  static const amberLight = Color(0xFFFFF6E5);
  static const amberDark = Color(0xFF3A2F1F);

  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFDEBEB);
  static const redDark = Color(0xFF3A1F1F);

  static const purple = Color(0xFF8B5CF6);
  static const purpleLight = Color(0xFFF1EBFE);
  static const purpleDark = Color(0xFF3A2A5A);

  static const teal = Color(0xFF14B8A6);
  static const tealDark = Color(0xFF1F3A36);

  // Dark theme palette
  static const textPrimary = Color(0xFFE8E8E8);
  static const textSecondary = Color(0xFF9CA3AF);
  static const textTertiary = Color(0xFF6B7280);

  static const border = Color(0xFF374151);
  static const surface = Color(0xFF1F2937);
  static const surfaceLight = Color(0xFF2D3748);
  static const background = Color(0xFF111827);
  static const cardBackground = Color(0xFF1A222F);
}

class AdminRadii {
  AdminRadii._();
  static const card = 16.0;
  static const chip = 20.0;
  static const button = 12.0;
}
