import 'package:flutter/material.dart';

/// BuildContext extensions for easy access to theme, navigation, etc.
extension ContextX on BuildContext {
  /// Theme access
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  /// Media query access
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  Size get screenSize => mediaQuery.size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  EdgeInsets get padding => mediaQuery.padding;
  EdgeInsets get viewInsets => mediaQuery.viewInsets;
  bool get isKeyboardOpen => viewInsets.bottom > 0;

  /// Device type checks
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1200;
  bool get isDesktop => screenWidth >= 1200;

  /// Orientation
  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;
  bool get isLandscape => mediaQuery.orientation == Orientation.landscape;

  /// Navigation shortcuts
  void pop<T>([T? result]) => Navigator.of(this).pop(result);
  void popUntil(RoutePredicate predicate) =>
      Navigator.of(this).popUntil(predicate);
  bool get canPop => Navigator.of(this).canPop();

  /// Focus
  void unfocus() => FocusScope.of(this).unfocus();

  /// Show snackbar
  void showSnackBar(
    String message, {
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Color? backgroundColor,
  }) {
    ScaffoldMessenger.of(this).clearSnackBars();
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: action,
        backgroundColor: backgroundColor,
      ),
    );
  }

  /// Show success snackbar
  void showSuccess(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }

  /// Show error snackbar
  void showError(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.red,
    );
  }

  /// Show loading dialog
  void showLoadingDialog({String? message}) {
    showDialog(
      context: this,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Text(message ?? 'Loading...'),
            ],
          ),
        ),
      ),
    );
  }

  /// Show confirmation dialog
  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: this,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous
                ? TextButton.styleFrom(foregroundColor: Colors.red)
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}

/// Widget extensions
extension WidgetX on Widget {
  /// Add padding
  Widget withPadding(EdgeInsetsGeometry padding) {
    return Padding(padding: padding, child: this);
  }

  /// Add all-sides padding
  Widget padAll(double value) {
    return Padding(padding: EdgeInsets.all(value), child: this);
  }

  /// Add symmetric padding
  Widget padSymmetric({double horizontal = 0, double vertical = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical),
      child: this,
    );
  }

  /// Add margin via Container
  Widget withMargin(EdgeInsetsGeometry margin) {
    return Container(margin: margin, child: this);
  }

  /// Make widget expanded
  Widget get expanded => Expanded(child: this);

  /// Make widget flexible
  Widget flexible([int flex = 1]) => Flexible(flex: flex, child: this);

  /// Center widget
  Widget get centered => Center(child: this);

  /// Wrap with SafeArea
  Widget get safeArea => SafeArea(child: this);

  /// Add opacity
  Widget withOpacity(double opacity) => Opacity(opacity: opacity, child: this);

  /// Wrap with GestureDetector
  Widget onTap(VoidCallback? onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }

  /// Wrap with InkWell
  Widget onTapInk(VoidCallback? onTap, {BorderRadius? borderRadius}) {
    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: this,
    );
  }

  /// Wrap with SliverToBoxAdapter
  Widget get sliver => SliverToBoxAdapter(child: this);
}
