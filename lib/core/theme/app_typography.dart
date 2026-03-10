import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Application typography configuration
abstract class AppTypography {
  static const String fontFamily = 'Cairo';

  /// Light theme text styles
  static TextTheme get textTheme => const TextTheme(
        // Display
        displayLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 57,
          fontWeight: FontWeight.w400,
          letterSpacing: -0.25,
          color: AppColors.textPrimary,
        ),
        displayMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 45,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        displaySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),

        // Headline
        headlineLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),

        // Title
        titleLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
          color: AppColors.textPrimary,
        ),
        titleSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: AppColors.textPrimary,
        ),

        // Body
        bodyLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.25,
          color: AppColors.textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.4,
          color: AppColors.textSecondary,
        ),

        // Label
        labelLarge: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          color: AppColors.textPrimary,
        ),
        labelMedium: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
          color: AppColors.textSecondary,
        ),
      );

  /// Dark theme text styles
  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: textTheme.displayLarge?.copyWith(color: AppColors.white),
        displayMedium: textTheme.displayMedium?.copyWith(color: AppColors.white),
        displaySmall: textTheme.displaySmall?.copyWith(color: AppColors.white),
        headlineLarge: textTheme.headlineLarge?.copyWith(color: AppColors.white),
        headlineMedium:
            textTheme.headlineMedium?.copyWith(color: AppColors.white),
        headlineSmall: textTheme.headlineSmall?.copyWith(color: AppColors.white),
        titleLarge: textTheme.titleLarge?.copyWith(color: AppColors.white),
        titleMedium: textTheme.titleMedium?.copyWith(color: AppColors.white),
        titleSmall: textTheme.titleSmall?.copyWith(color: AppColors.white),
        bodyLarge: textTheme.bodyLarge?.copyWith(color: AppColors.white),
        bodyMedium: textTheme.bodyMedium?.copyWith(color: AppColors.white),
        bodySmall: textTheme.bodySmall?.copyWith(color: AppColors.grey400),
        labelLarge: textTheme.labelLarge?.copyWith(color: AppColors.white),
        labelMedium: textTheme.labelMedium?.copyWith(color: AppColors.white),
        labelSmall: textTheme.labelSmall?.copyWith(color: AppColors.grey400),
      );
}

/// Text style extensions
extension TextStyleX on TextStyle {
  TextStyle get bold => copyWith(fontWeight: FontWeight.bold);
  TextStyle get semiBold => copyWith(fontWeight: FontWeight.w600);
  TextStyle get medium => copyWith(fontWeight: FontWeight.w500);
  TextStyle get regular => copyWith(fontWeight: FontWeight.w400);

  TextStyle withColor(Color color) => copyWith(color: color);
  TextStyle withSize(double size) => copyWith(fontSize: size);
}
