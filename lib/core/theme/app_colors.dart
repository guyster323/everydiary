import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 색상 정의
class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF6366F1); // Indigo-500
  static const Color primaryLight = Color(0xFF818CF8); // Indigo-400
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo-600

  // Secondary Colors
  static const Color secondary = Color(0xFF10B981); // Emerald-500
  static const Color secondaryLight = Color(0xFF34D399); // Emerald-400
  static const Color secondaryDark = Color(0xFF059669); // Emerald-600

  // Background Colors
  static const Color background = Color(0xFFF8FAFC); // Slate-50
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color surfaceVariant = Color(0xFFF1F5F9); // Slate-100

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textTertiary = Color(0xFF94A3B8); // Slate-400
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White

  // Border Colors
  static const Color border = Color(0xFFE2E8F0); // Slate-200
  static const Color borderLight = Color(0xFFF1F5F9); // Slate-100
  static const Color borderDark = Color(0xFFCBD5E1); // Slate-300

  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald-500
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color error = Color(0xFFEF4444); // Red-500
  static const Color info = Color(0xFF3B82F6); // Blue-500

  // Neutral Colors
  static const Color neutral50 = Color(0xFFF8FAFC); // Slate-50
  static const Color neutral100 = Color(0xFFF1F5F9); // Slate-100
  static const Color neutral200 = Color(0xFFE2E8F0); // Slate-200
  static const Color neutral300 = Color(0xFFCBD5E1); // Slate-300
  static const Color neutral400 = Color(0xFF94A3B8); // Slate-400
  static const Color neutral500 = Color(0xFF64748B); // Slate-500
  static const Color neutral600 = Color(0xFF475569); // Slate-600
  static const Color neutral700 = Color(0xFF334155); // Slate-700
  static const Color neutral800 = Color(0xFF1E293B); // Slate-800
  static const Color neutral900 = Color(0xFF0F172A); // Slate-900

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow Colors
  static const Color shadowLight = Color(0x0A000000); // 4% opacity
  static const Color shadowMedium = Color(0x14000000); // 8% opacity
  static const Color shadowDark = Color(0x1F000000); // 12% opacity
}

