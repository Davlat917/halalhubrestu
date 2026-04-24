import 'package:flutter/widgets.dart';

/// Breakpoints — industry standard (Material Design 3)
///
///  < 600px   → Mobile (shortest side)
///  ≥ 600px   → Tablet (shortest side)
///  ≥ 1440px  → Desktop (width) - iPad Pro'lar uchun 1440px qilingan!

abstract class ResponsiveSection extends StatelessWidget {
  const ResponsiveSection({super.key});

  /// Material 3 — qisqa tomon bo‘yicha telefon / planshet chegarasi.
  static const double mobileBreakpoint = 600.0;

  /// Keng monitor / iPad Pro kabi — `width` bo‘yicha.
  static const double desktopBreakpoint = 1440.0;

  /// Modal, dialog, boshqa joylarda [ResponsiveSection] meros olmasdan ishlatish.
  static bool isMobileLayout(BuildContext context) {
    return MediaQuery.sizeOf(context).shortestSide < mobileBreakpoint;
  }

  // ─── MAJBURIY override qilinadigan metodlar ──────────────────────────────
  Widget buildMobile(BuildContext context);
  Widget buildTablet(BuildContext context);

  // ─── IXTIYORIY override qilinadigan metodlar ─────────────────────────────
  Widget buildDesktop(BuildContext context) => buildTablet(context);
  
  // Mobile va Tablet uchun maxsus landscape metodlari
  Widget? buildMobileLandscape(BuildContext context) => null;
  Widget? buildTabletLandscape(BuildContext context) => null;

  // ─── Device yordamchilari (Helpers) ──────────────────────────────────────
  bool isMobile(BuildContext context) => isMobileLayout(context);

  bool isTablet(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return size.shortestSide >= mobileBreakpoint && size.width < desktopBreakpoint;
  }

  bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= desktopBreakpoint;
  
  bool isLandscape(BuildContext context) => MediaQuery.orientationOf(context) == Orientation.landscape;

  // ─── Asosiy Build Logikasi ───────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final landscape = isLandscape(context);

    // 1. Desktop (Eng keng ekranlar)
    if (size.width >= desktopBreakpoint) {
      return buildDesktop(context);
    }

    // 2. Mobile (Eng birinchi qisqa tomon tekshiriladi)
    if (isMobile(context)) {
      if (landscape) {
        final mobileLandscape = buildMobileLandscape(context);
        if (mobileLandscape != null) return mobileLandscape;
      }
      return buildMobile(context);
    }

    // 3. Tablet (Qolgan holatlar, shu jumladan iPad Pro)
    if (landscape) {
      final tabletLandscape = buildTabletLandscape(context);
      if (tabletLandscape != null) return tabletLandscape;
    }
    
    return buildTablet(context);
  }
}