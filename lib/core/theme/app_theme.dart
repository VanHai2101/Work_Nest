import 'package:flutter/material.dart';
import 'index.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.primaryBackground,
    fontFamily: 'Poppins',

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.primaryBackground,
      secondary: AppColors.accent,
      onSecondary: AppColors.primaryBackground,
      tertiary: AppColors.accent,
      onTertiary: AppColors.primaryBackground,
      surface: AppColors.surface,
      error: AppColors.error,
      onError: AppColors.textPrimary,
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primaryBackground,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.inputBackground,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      hintStyle: TextStyle(color: AppColors.textTertiary, fontSize: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(0),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
      displayMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
      headlineLarge: AppTextStyles.titleLarge.copyWith(color: AppColors.textPrimary),
      headlineMedium: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
      titleLarge: AppTextStyles.titleMedium.copyWith(color: AppColors.textPrimary),
      titleMedium: AppTextStyles.subtitle.copyWith(color: AppColors.textPrimary),
      bodyLarge: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
      bodyMedium: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      bodySmall: AppTextStyles.caption.copyWith(color: AppColors.textTertiary),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.primaryBackground,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),

    // Floating Action Button
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.primaryBackground,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Extensions
    extensions: <ThemeExtension<dynamic>>[CustomColors.dark()],
  );

  static ThemeData get lightTheme => darkTheme; // Placeholder
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
