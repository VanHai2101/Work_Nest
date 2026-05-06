import 'package:flutter/material.dart';

/// =======================================================
/// AppColors (PUBLIC API)
/// =======================================================
class AppColors {
  AppColors._();

  // ==================== PRIMARY COLORS ====================

  static Color get primaryBackground => _AppColor.primaryBackground.color;
  static Color get accent => _AppColor.accent.color;
  static Color get accentLight => _AppColor.accentLight.color;
  static Color get accentDark => _AppColor.accentDark.color;

  // ==================== TEXT COLORS ====================

  static Color get textPrimary => _AppColor.textPrimary.color;
  static Color get textSecondary => _AppColor.textSecondary.color;
  static Color get textTertiary => _AppColor.textTertiary.color;

  // ==================== BACKGROUND COLORS ====================

  static Color get surface => _AppColor.surface.color;
  static Color get surfaceVariant => _AppColor.surfaceVariant.color;
  static Color get card => _AppColor.card.color;

  // ==================== BORDER & DIVIDER ====================

  static Color get border => _AppColor.border.color;
  static Color get borderLight => _AppColor.borderLight.color;
  static Color get divider => _AppColor.divider.color;

  // ==================== STATE COLORS ====================

  static Color get success => _AppColor.success.color;
  static Color get warning => _AppColor.warning.color;
  static Color get error => _AppColor.error.color;
  static Color get info => _AppColor.info.color;

  static Color get disabled => _AppColor.disabled.color;
  static Color get disabledBackground => _AppColor.disabledBackground.color;
  static Color get overlay => _AppColor.overlay.color;
  static Color get transparent => Colors.transparent;

  static Color get inputBackground => _AppColor.inputBackground.color;
  static Color get inputFocus => _AppColor.inputFocus.color;
  static Color get chipBackground => _AppColor.chipBackground.color;
  static Color get skeleton => _AppColor.skeleton.color;

  static const List<Color> projectPalette = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
    Color(0xFFEAB308), // Yellow
    Color(0xFF22C55E), // Green
    Color(0xFF06B6D4), // Cyan
    Color(0xFF3B82F6), // Blue
    Color(0xFF8B5CF6), // Violet
    Color(0xFFEC4899), // Pink
  ];

  static const List<Color> avatarColors = projectPalette;

  // ==================== PREMIUM DARK PALETTE ====================
  // Used for high-fidelity dark-themed screens

  static const Color darkBg = Color(0xFF0F1117);
  static const Color darkSurface = Color(0xFF161B24);
  static const Color darkCard = Color(0xFF1A2030);
  static const Color darkBorder = Color(0xFF252D3D);
  static const Color darkTextSecondary = Color(0xFF6B7A99);
  static const Color darkTextHint = Color(0xFF3A4560);
  static const Color darkAccent = Color(0xFF4F46E5);
  static const Color darkAccentLight = Color(0xFF60A5FA);
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkSuccessBg = Color(0xFF1A2E23);
  static const Color darkSuccessBorder = Color(0xFF0B6E38);
  static const Color darkWarningBg = Color(0xFF2A2010);
  static const Color darkWarningBorder = Color(0xFF856C0A);
  static const Color darkErrorBg = Color(0xFF2A1414);
  static const Color darkErrorBorder = Color(0xFF8B2020);

  static const List<Color> darkAvatarPalette = [
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFF10B981),
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
    Color(0xFFEC4899),
  ];
  static Color getColorByBrightness(
    Color darkColor,
    Color lightColor, {
    required Brightness brightness,
  }) {
    return brightness == Brightness.dark ? darkColor : lightColor;
  }

  static Color getStateColor(StateType type) {
    return type.color;
  }
}

enum _AppColor {
  primaryBackground,
  accent,
  accentLight,
  accentDark,
  textPrimary,
  textSecondary,
  textTertiary,
  surface,
  surfaceVariant,
  card,
  border,
  borderLight,
  divider,
  success,
  warning,
  error,
  info,
  disabled,
  disabledBackground,
  overlay,
  inputBackground,
  inputFocus,
  chipBackground,
  skeleton,
}

extension _AppColorExtension on _AppColor {
  Color get color {
    switch (this) {
      case _AppColor.primaryBackground:
        return const Color(0xFFFFFFFF);
      case _AppColor.accent:
        return const Color(0xFF4F46E5); // Modern Indigo
      case _AppColor.accentLight:
        return const Color(0xFFEEF2FF); // Indigo 50
      case _AppColor.accentDark:
        return const Color(0xFF3730A3); // Indigo 800
      case _AppColor.textPrimary:
        return const Color(0xFF0F172A); // Slate 900
      case _AppColor.textSecondary:
        return const Color(0xFF64748B); // Slate 500
      case _AppColor.textTertiary:
        return const Color(0xFF94A3B8); // Slate 400
      case _AppColor.surface:
        return const Color(0xFFF8FAFC); // Slate 50
      case _AppColor.surfaceVariant:
        return const Color(0xFFF1F5F9); // Slate 100
      case _AppColor.card:
        return const Color(0xFFFFFFFF);
      case _AppColor.border:
        return const Color(0xFFE2E8F0); // Slate 200
      case _AppColor.borderLight:
        return const Color(0xFFF1F5F9);
      case _AppColor.divider:
        return const Color(0xFFF1F5F9);
      case _AppColor.success:
        return const Color(0xFF10B981);
      case _AppColor.warning:
        return const Color(0xFFF59E0B);
      case _AppColor.error:
        return const Color(0xFFEF4444);
      case _AppColor.info:
        return const Color(0xFF3B82F6);
      case _AppColor.disabled:
        return const Color(0xFFCBD5E1);
      case _AppColor.disabledBackground:
        return const Color(0xFFF1F5F9);
      case _AppColor.overlay:
        return const Color(0x660F172A);
      case _AppColor.inputBackground:
        return const Color(0xFFF8FAFC);
      case _AppColor.inputFocus:
        return const Color(0xFFE2E8F0);
      case _AppColor.chipBackground:
        return const Color(0xFFF1F5F9);
      case _AppColor.skeleton:
        return const Color(0xFFF1F5F9);
    }
  }
}

enum StateType { success, warning, error, info }

extension StateTypeExtension on StateType {
  Color get color {
    switch (this) {
      case StateType.success:
        return AppColors.success;
      case StateType.warning:
        return AppColors.warning;
      case StateType.error:
        return AppColors.error;
      case StateType.info:
        return AppColors.info;
    }
  }
}
