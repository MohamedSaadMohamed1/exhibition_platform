import 'package:flutter/material.dart';

/// Application dimensions and spacing
class AppDimensions {
  AppDimensions._();

  // Spacing
  static const double spacingXxs = 2.0;
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 12.0;
  static const double spacingLg = 16.0;
  static const double spacingXl = 20.0;
  static const double spacingXxl = 24.0;
  static const double spacing3xl = 32.0;
  static const double spacing4xl = 40.0;
  static const double spacing5xl = 48.0;

  // Padding
  static const EdgeInsets paddingXs = EdgeInsets.all(spacingXs);
  static const EdgeInsets paddingSm = EdgeInsets.all(spacingSm);
  static const EdgeInsets paddingMd = EdgeInsets.all(spacingMd);
  static const EdgeInsets paddingLg = EdgeInsets.all(spacingLg);
  static const EdgeInsets paddingXl = EdgeInsets.all(spacingXl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(spacingXxl);

  // Horizontal padding
  static const EdgeInsets paddingHorizontalSm =
      EdgeInsets.symmetric(horizontal: spacingSm);
  static const EdgeInsets paddingHorizontalMd =
      EdgeInsets.symmetric(horizontal: spacingMd);
  static const EdgeInsets paddingHorizontalLg =
      EdgeInsets.symmetric(horizontal: spacingLg);
  static const EdgeInsets paddingHorizontalXl =
      EdgeInsets.symmetric(horizontal: spacingXl);

  // Vertical padding
  static const EdgeInsets paddingVerticalSm =
      EdgeInsets.symmetric(vertical: spacingSm);
  static const EdgeInsets paddingVerticalMd =
      EdgeInsets.symmetric(vertical: spacingMd);
  static const EdgeInsets paddingVerticalLg =
      EdgeInsets.symmetric(vertical: spacingLg);
  static const EdgeInsets paddingVerticalXl =
      EdgeInsets.symmetric(vertical: spacingXl);

  // Screen padding
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: spacingLg,
    vertical: spacingLg,
  );
  static const EdgeInsets screenPaddingHorizontal =
      EdgeInsets.symmetric(horizontal: spacingLg);

  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radiusXxl = 24.0;
  static const double radiusCircle = 999.0;

  // Border radius objects
  static final BorderRadius borderRadiusXs = BorderRadius.circular(radiusXs);
  static final BorderRadius borderRadiusSm = BorderRadius.circular(radiusSm);
  static final BorderRadius borderRadiusMd = BorderRadius.circular(radiusMd);
  static final BorderRadius borderRadiusLg = BorderRadius.circular(radiusLg);
  static final BorderRadius borderRadiusXl = BorderRadius.circular(radiusXl);
  static final BorderRadius borderRadiusXxl = BorderRadius.circular(radiusXxl);
  static final BorderRadius borderRadiusCircle =
      BorderRadius.circular(radiusCircle);

  // Top only border radius
  static final BorderRadius borderRadiusTopLg = const BorderRadius.only(
    topLeft: Radius.circular(radiusLg),
    topRight: Radius.circular(radiusLg),
  );
  static final BorderRadius borderRadiusTopXl = const BorderRadius.only(
    topLeft: Radius.circular(radiusXl),
    topRight: Radius.circular(radiusXl),
  );

  // Icon sizes
  static const double iconXs = 12.0;
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;
  static const double icon3xl = 64.0;

  // Button sizes
  static const double buttonHeightSm = 36.0;
  static const double buttonHeightMd = 44.0;
  static const double buttonHeightLg = 52.0;
  static const double buttonHeightXl = 60.0;

  // Avatar sizes
  static const double avatarXs = 24.0;
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 72.0;
  static const double avatarXxl = 96.0;
  static const double avatar3xl = 120.0;

  // Card dimensions
  static const double cardElevation = 0.0;
  static const double cardElevationHover = 4.0;

  // Input field height
  static const double inputHeight = 52.0;
  static const double inputHeightSm = 44.0;
  static const double inputHeightLg = 60.0;

  // Bottom navigation height
  static const double bottomNavHeight = 64.0;
  static const double bottomNavHeightWithPadding = 80.0;

  // App bar height
  static const double appBarHeight = 56.0;
  static const double appBarHeightLg = 64.0;

  // Tab bar height
  static const double tabBarHeight = 48.0;

  // Image aspect ratios
  static const double aspectRatioBanner = 16 / 9;
  static const double aspectRatioCard = 4 / 3;
  static const double aspectRatioSquare = 1;
  static const double aspectRatioPortrait = 3 / 4;

  // Max widths (for responsive design)
  static const double maxWidthMobile = 600.0;
  static const double maxWidthTablet = 900.0;
  static const double maxWidthDesktop = 1200.0;

  // Grid
  static const int gridColumnsMobile = 2;
  static const int gridColumnsTablet = 3;
  static const int gridColumnsDesktop = 4;
  static const double gridSpacing = spacingLg;

  // Divider
  static const double dividerThickness = 1.0;
  static const double dividerThicknessBold = 2.0;
}
