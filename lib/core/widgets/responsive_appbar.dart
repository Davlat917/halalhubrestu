import 'package:flutter/material.dart';

/// AppBar uchun responsive abstract class.

abstract class ResponsiveAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ResponsiveAppBar({super.key, this.toolbarHeight = 80.0, this.bottom});

  final double toolbarHeight;
  final PreferredSizeWidget? bottom;

  // ─── Override qilinadigan metodlar ───────────────────────────────────────

  /// Majburiy
  PreferredSizeWidget buildMobile(BuildContext context);

  /// Majburiy
  PreferredSizeWidget buildTablet(BuildContext context);

  /// Optional — aks holda [buildTablet] qaytaradi
  PreferredSizeWidget buildDesktop(BuildContext context) => buildTablet(context);

  /// Optional — portrait uchun alohida kerak bo'lsa
  PreferredSizeWidget? buildPortrait(BuildContext context) => null;

  /// Optional — landscape uchun alohida kerak bo'lsa
  PreferredSizeWidget? buildLandscape(BuildContext context) => null;

  // ─── Breakpoints ─────────────────────────────────────────────────────────

  static const double _mobileBreakpoint = 600.0;
  static const double _desktopBreakpoint = 1200.0;

  // ─── Device type ─────────────────────────────────────────────────────────

  bool isMobile(BuildContext context) => MediaQuery.sizeOf(context).width < _mobileBreakpoint;

  bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= _mobileBreakpoint && width < _desktopBreakpoint;
  }

  bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= _desktopBreakpoint;

  // ─── Orientation ─────────────────────────────────────────────────────────

  bool isPortrait(BuildContext context) => MediaQuery.orientationOf(context) == Orientation.portrait;

  bool isLandscape(BuildContext context) => MediaQuery.orientationOf(context) == Orientation.landscape;

  // ─── preferredSize ────────────────────────────────────────────────────────

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight + (bottom?.preferredSize.height ?? 0));

  // ─── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.orientationOf(context);
    final width = MediaQuery.sizeOf(context).width;

    // 1. Orientation override — agar implement qilingan bo'lsa
    if (orientation == Orientation.portrait) {
      final w = buildPortrait(context);
      if (w != null) return w;
    }

    if (orientation == Orientation.landscape) {
      final w = buildLandscape(context);
      if (w != null) return w;
    }

    // 2. Breakpoint asosida
    if (width >= _desktopBreakpoint) return buildDesktop(context);
    if (width >= _mobileBreakpoint) return buildTablet(context);
    return buildMobile(context);
  }
}
