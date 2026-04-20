import 'package:flutter/material.dart';
import '../extensions/context_extensions.dart';
import '../theme/app_dimensions.dart';

/// Branches between mobile / tablet / desktop layouts.
/// Uses existing ContextX breakpoints: isMobile < 600, isTablet 600–1200.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isDesktop && desktop != null) return desktop!;
    if (context.isTablet && tablet != null) return tablet!;
    return mobile;
  }
}

/// Constrains forms/content to maxWidth and centers them on wide screens.
/// Pass [maxWidth] to override the default (AppDimensions.maxWidthMobile = 600).
class ResponsiveConstrainedBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveConstrainedBox({
    super.key,
    required this.child,
    this.maxWidth = AppDimensions.maxWidthMobile,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
