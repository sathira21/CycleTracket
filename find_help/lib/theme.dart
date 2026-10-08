import 'package:flutter/material.dart';

class AppColors {
  static const blush = Color(0xFFFFF6F9);
  static const blushDeep = Color(0xFFFCE8F2);
  static const primary = Color(0xFFE21886);
  static const primaryDark = Color(0xFF9F0D71);
  static const plum = Color(0xFF3A122C);
  static const ink = Color(0xFF1C1220);
  static const muted = Color(0xFF8B7382);
  static const line = Color(0xFFF3D6E6);
  static const card = Color(0xFFFCE8F2);
  static const teal = Color(0xFFE21886);
  static const tealDeep = Color(0xFF3A122C);

  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4B9A), Color(0xFFC2186A)],
  );

  static const cardShadow = [
    BoxShadow(
      color: Color(0x16E21886),
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.blush,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.card,
    ),
    splashFactory: InkRipple.splashFactory,
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.plum,
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: Color(0xFFC4A8B6), fontWeight: FontWeight.w500),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE8E0E5)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE8E0E5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
    ),
  );
}
