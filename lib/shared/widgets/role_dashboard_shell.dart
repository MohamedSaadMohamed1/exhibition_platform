import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';

/// Navigation item configuration
class NavItem {
  final IconData icon;
  final String label;
  final String? route;
  final VoidCallback? onTap;

  const NavItem({
    required this.icon,
    required this.label,
    this.route,
    this.onTap,
  });
}

/// Reusable dashboard shell with role-based bottom navigation
class RoleDashboardShell extends StatelessWidget {
  final Widget body;
  final int currentIndex;
  final List<NavItem> navItems;
  final ValueChanged<int> onNavTap;
  final Color? accentColor;
  final bool showFloatingNav;

  const RoleDashboardShell({
    super.key,
    required this.body,
    required this.currentIndex,
    required this.navItems,
    required this.onNavTap,
    this.accentColor,
    this.showFloatingNav = true,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final color = accentColor ?? AppColors.primary;

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      extendBody: showFloatingNav,
      body: body,
      bottomNavigationBar: showFloatingNav
          ? Container(
              margin: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h + bottomPadding),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.15),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(navItems.length, (index) {
                        return _NavItem(
                          icon: navItems[index].icon,
                          label: navItems[index].label,
                          isSelected: currentIndex == index,
                          accentColor: color,
                          onTap: () => onNavTap(index),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            )
          : BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: onNavTap,
              type: BottomNavigationBarType.fixed,
              backgroundColor: AppColors.surfaceDark,
              selectedItemColor: color,
              unselectedItemColor: AppColors.grey500,
              items: navItems.map((item) {
                return BottomNavigationBarItem(
                  icon: Icon(item.icon),
                  label: item.label,
                );
              }).toList(),
            ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color accentColor;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 16.w : 12.w,
          vertical: 8.h,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    accentColor,
                    accentColor.withOpacity(0.8),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
              size: 22.r,
            ),
            if (isSelected) ...[
              SizedBox(width: 6.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
