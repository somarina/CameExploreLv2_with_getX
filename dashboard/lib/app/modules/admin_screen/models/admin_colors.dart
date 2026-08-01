import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/theme_controller.dart';

/// Shared style constants for the Admin Dashboard UI.
/// Kept in one place so the whole dashboard stays visually consistent.
///
/// Structural colors (background/surface/border/text) switch with
/// [ThemeController.isDarkMode]. Brand/status colors stay the same in
/// both modes.
class AdminColors {
  AdminColors._();

  static bool get _isDark {
    try {
      return Get.find<ThemeController>().isDarkMode.value;
    } catch (_) {
      return true;
    }
  }

  // Primary colors
  static const primary = Color(0xFF00C17C);
  static const primaryLight = Color(0xFFDFF7EC);
  static const primaryDark = Color(0xFF00915C);

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

  // ── Structural palette (theme-aware) ──
  static Color get textPrimary =>
      _isDark ? const Color(0xFFE8E8E8) : const Color(0xFF111827);
  static Color get textSecondary =>
      _isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B);
  static Color get textTertiary =>
      _isDark ? const Color(0xFF6B7280) : const Color(0xFF94A3B8);

  static Color get border =>
      _isDark ? const Color(0xFF374151) : const Color(0xFFE2E8F0);
  static Color get surface =>
      _isDark ? const Color(0xFF1F2937) : const Color(0xFFFFFFFF);
  static Color get surfaceLight =>
      _isDark ? const Color(0xFF2D3748) : const Color(0xFFF1F5F9);
  static Color get background =>
      _isDark ? const Color(0xFF111827) : const Color(0xFFF7F9FC);
  static Color get cardBackground =>
      _isDark ? const Color(0xFF1A222F) : const Color(0xFFFFFFFF);
}

class AdminRadii {
  AdminRadii._();
  static const card = 16.0;
  static const chip = 20.0;
  static const button = 12.0;
}
