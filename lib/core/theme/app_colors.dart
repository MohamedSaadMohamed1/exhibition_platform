import 'package:flutter/material.dart';

/// Application color palette - Dark Purple Theme
abstract class AppColors {
  // Primary Colors (Purple)
  static const Color primary = Color(0xFF8B5CF6);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF7C3AED);

  // Secondary Colors
  static const Color secondary = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);

  // Accent Colors (Teal/Green)
  static const Color accent = Color(0xFF06D6A0);
  static const Color accentLight = Color(0xFF6FFFE9);
  static const Color accentDark = Color(0xFF00B388);

  // Background Colors (Dark)
  static const Color scaffoldDark = Color(0xFF0D0B14);
  static const Color backgroundDark = Color(0xFF110E19);
  static const Color surfaceDark = Color(0xFF1A1525);
  static const Color cardDark = Color(0xFF1E1830);

  // Light theme backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);

  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF4F4F5);
  static const Color grey200 = Color(0xFFE4E4E7);
  static const Color grey300 = Color(0xFFD4D4D8);
  static const Color grey400 = Color(0xFFA1A1AA);
  static const Color grey500 = Color(0xFF71717A);
  static const Color grey600 = Color(0xFF52525B);
  static const Color grey700 = Color(0xFF3F3F46);
  static const Color grey800 = Color(0xFF27272A);
  static const Color grey900 = Color(0xFF18181B);

  // Text Colors - Dark Theme
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textMutedDark = Color(0xFF6B7280);

  // Text Colors - Light Theme
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF94A3B8);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Semantic Colors
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // Interest/Like color (green heart from design)
  static const Color interested = Color(0xFF06D6A0);

  // Tag colors
  static const Color tagBackground = Color(0xFF2D2640);
  static const Color tagBorder = Color(0xFF3D3650);
  static const Color tagText = Color(0xFFE5E7EB);

  // Tab colors
  static const Color tabActive = Color(0xFF8B5CF6);
  static const Color tabInactive = Color(0xFF6B7280);

  // Role Colors
  static const Color adminColor = Color(0xFFEF4444);
  static const Color ownerColor = Color(0xFFF59E0B);
  static const Color organizerColor = Color(0xFF8B5CF6);
  static const Color supplierColor = Color(0xFF10B981);
  static const Color exhibitorColor = Color(0xFF06B6D4);
  static const Color visitorColor = Color(0xFF3B82F6);

  // Status Colors
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusApproved = Color(0xFF22C55E);
  static const Color statusRejected = Color(0xFFEF4444);
  static const Color statusCancelled = Color(0xFF6B7280);

  // Booth Status Colors
  static const Color boothAvailable = Color(0xFF22C55E);
  static const Color boothReserved = Color(0xFFF59E0B);
  static const Color boothBooked = Color(0xFF3B82F6);
  static const Color boothOccupied = Color(0xFFEF4444);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient bottomNavGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Shadow
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: black.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: primary.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get bottomNavShadow => [
        BoxShadow(
          color: primary.withOpacity(0.2),
          blurRadius: 20,
          offset: const Offset(0, -5),
        ),
      ];
}
