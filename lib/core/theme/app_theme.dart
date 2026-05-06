import 'package:flutter/material.dart';
import 'index.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.primaryBackground,
    fontFamily: 'Poppins',

    // Color Scheme
    colorScheme: ColorScheme.light(
      primary: AppColors.accent,
      onPrimary: Colors.white,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryBackground,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        fontFamily: 'Poppins',
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.accent, width: 1.5),
      ),
    ),

    // Button Themes
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.border),
        ),
      ),
    ),

    // Extensions
    extensions: <ThemeExtension<dynamic>>[CustomColors.dark()],
  );

  static ThemeData get darkTheme => lightTheme; // For now, keep unified
}

class CustomColors extends ThemeExtension<CustomColors> {
  const CustomColors({
    required this.success,
    required this.warning,
    required this.info,
    required this.textTertiary,
    required this.chipBackground,
    required this.inputBackground,
    required this.accent,
    required this.accentLight,
    required this.accentDark,
  });

  factory CustomColors.dark() => CustomColors(
    success: AppColors.success,
    warning: AppColors.warning,
    info: AppColors.info,
    textTertiary: AppColors.textTertiary,
    chipBackground: AppColors.chipBackground,
    inputBackground: AppColors.inputBackground,
    accent: AppColors.accent,
    accentLight: AppColors.accentLight,
    accentDark: AppColors.accentDark,
  );

  final Color success;
  final Color warning;
  final Color info;
  final Color textTertiary;
  final Color chipBackground;
  final Color inputBackground;
  final Color accent;
  final Color accentLight;
  final Color accentDark;

  @override
  CustomColors copyWith({
    Color? success,
    Color? warning,
    Color? info,
    Color? textTertiary,
    Color? chipBackground,
    Color? inputBackground,
    Color? accent,
    Color? accentLight,
    Color? accentDark,
  }) {
    return CustomColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      textTertiary: textTertiary ?? this.textTertiary,
      chipBackground: chipBackground ?? this.chipBackground,
      inputBackground: inputBackground ?? this.inputBackground,
      accent: accent ?? this.accent,
      accentLight: accentLight ?? this.accentLight,
      accentDark: accentDark ?? this.accentDark,
    );
  }

  @override
  CustomColors lerp(CustomColors? other, double t) {
    if (other is! CustomColors) {
      return this;
    }
    return CustomColors(
      success: Color.lerp(success, other.success, t) ?? success,
      warning: Color.lerp(warning, other.warning, t) ?? warning,
      info: Color.lerp(info, other.info, t) ?? info,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t) ?? textTertiary,
      chipBackground: Color.lerp(chipBackground, other.chipBackground, t) ?? chipBackground,
      inputBackground: Color.lerp(inputBackground, other.inputBackground, t) ?? inputBackground,
      accent: Color.lerp(accent, other.accent, t) ?? accent,
      accentLight: Color.lerp(accentLight, other.accentLight, t) ?? accentLight,
      accentDark: Color.lerp(accentDark, other.accentDark, t) ?? accentDark,
    );
  }
}
