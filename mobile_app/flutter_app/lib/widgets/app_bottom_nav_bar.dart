import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_theme.dart';

enum BottomNavTab { dashboard, camera, settings }

/// Total height consumed by the bottom nav including the floating camera button.
double appBottomNavTotalHeight(BuildContext context) {
  final bottomInset = MediaQuery.paddingOf(context).bottom;
  return AppBottomNavBar.barHeight + AppBottomNavBar.cameraFloat + bottomInset;
}

class AppBottomNavBar extends StatelessWidget {
  static const double barHeight = AppTheme.navBarHeight;
  static const double cameraSize = AppTheme.cameraButtonSize;
  static const double cameraFloat = AppTheme.cameraButtonFloat;

  final BottomNavTab activeTab;
  final VoidCallback? onDashboard;
  final VoidCallback? onCamera;
  final VoidCallback? onSettings;
  final bool centerIsCapture;
  final VoidCallback? onCapture;
  final bool isCaptureLoading;

  const AppBottomNavBar({
    super.key,
    required this.activeTab,
    this.onDashboard,
    this.onCamera,
    this.onSettings,
    this.centerIsCapture = false,
    this.onCapture,
    this.isCaptureLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: barHeight + cameraFloat + bottomInset,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: bottomInset,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusNavBar),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: AppTheme.navBarBg.withValues(alpha: 0.92),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusNavBar),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.55),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _NavItem(
                          icon: Icons.grid_view_rounded,
                          label: 'Dashboard',
                          isActive: activeTab == BottomNavTab.dashboard,
                          onTap: onDashboard,
                        ),
                        SizedBox(width: cameraSize),
                        _NavItem(
                          icon: Icons.settings_outlined,
                          label: 'Settings',
                          isActive: activeTab == BottomNavTab.settings,
                          onTap: onSettings,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: bottomInset + barHeight - cameraFloat,
            child: GestureDetector(
              onTap: centerIsCapture
                  ? (isCaptureLoading ? null : onCapture)
                  : onCamera,
              child: Container(
                width: cameraSize,
                height: cameraSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB5A6FF),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: isCaptureLoading
                    ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.camera_alt, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppTheme.quoteText
        : AppTheme.quoteText.withValues(alpha: 0.45);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 72,
        height: 44,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: AppTheme.labelSize,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
