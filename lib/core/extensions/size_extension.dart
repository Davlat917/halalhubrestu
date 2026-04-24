import 'package:flutter/widgets.dart';

/// ResponsiveSize — barcha o'lchamlarni ekran yoki
/// berilgan [availableWidth] ga nisbatan hisoblaydi.
///
/// Muammo:
///   MediaQuery.of(context).size.width — har doim BUTUN ekran kengligini beradi.
///   Agar Row > Flexible ichida ishlasak, haqiqiy kenlik kichikroq bo'ladi,
///   lekin extension buni bilmaydi → o'lchamlar noto'g'ri chiqadi.
///
/// Yechim:
///   LayoutBuilder orqali haqiqiy kenglikni olib, [wOf] va [spOf] metodlariga
///   o'tkazamiz. Shunda Flexible ichidagi widget o'z haqiqiy maydoniga
///   nisbatan scale bo'ladi.

extension ResponsiveSize on BuildContext {
  // ─── Design token'lar (bazaviy dizayn o'lchamlari) ───────────────────────
  //
  // Dizayner qaysi qurilmada ishlagan bo'lsa, shu yerga yoziladi.
  // Bizning holda: iPhone 14 Pro (393x852, 3x DPI)

  static const double _designWidth = 393.0;
  static const double _designHeight = 852.0;
  static const double _designPixelRatio = 3.0;
  static const double _designRatio = _designWidth / _designHeight;

  // Shrift uchun minimal/maksimal scale chegaralari
  static const double _minFontScale = 0.85;
  static const double _maxFontScale = 1.30;

  // ─── MediaQuery shortcuts ─────────────────────────────────────────────────

  MediaQueryData get _mq => MediaQuery.of(this);

  double get screenWidth => _mq.size.width;
  double get screenHeight => _mq.size.height;
  double get pixelRatio => _mq.devicePixelRatio;
  double get statusBarHeight => _mq.padding.top;
  double get bottomBarHeight => _mq.padding.bottom;

  /// Ekranning width/height nisbati
  /// Narrow (< 0.42) → oddiy uzun telefon
  /// Normal (0.42–0.50) → standart telefon
  /// Wide (0.50–0.75) → kichik tablet yoki landscape telefon
  /// Tablet (> 0.75) → planshet
  double get aspectRatio => screenWidth / screenHeight;

  // ─── Ekran turlari ───────────────────────────────────────────────────────

  bool get isNarrow => aspectRatio < 0.42;
  bool get isNormal => aspectRatio >= 0.42 && aspectRatio <= 0.50;
  bool get isWide => aspectRatio > 0.50 && aspectRatio <= 0.75;
  bool get isTablet => aspectRatio > 0.75;

  // ─── Asosiy scale koeffitsiyentlari ──────────────────────────────────────

  /// Butun ekran kengligiga asoslangan koeffitsiyent
  /// Masalan: ekran 786px → _baseWidth = 786/393 = 2.0
  double get _baseWidth => screenWidth / _designWidth;

  /// Butun ekran balandligiga asoslangan koeffitsiyent
  double get _baseHeight => screenHeight / _designHeight;

  // ─── Asosiy funksiyalar (butun ekranga nisbatan) ──────────────────────────
  //
  // Bu metodlar faqat to'liq ekranda ishlaydigan widgetlar uchun to'g'ri.
  // Flexible/Column/Row ichida ishlatiladigan widgetlar uchun
  // quyidagi [wOf] va [spOf] metodlarini ishlating.

  /// Width-based scaling — gorizontal o'lchamlar uchun
  double w(double px) => px * _baseWidth;

  /// Height-based scaling — vertikal o'lchamlar uchun
  double h(double px) => px * _baseHeight;

  /// Radius uchun — width asosida
  double r(double px) => px * _baseWidth;

  /// Shrift o'lchami — pixel ratio va aspect ratio hisobga olingan
  double sp(double px) {
    // Yuqori DPI ekranlarda shrift kichikroq ko'rinadi → kompensatsiya
    final pixelScale = _baseWidth * (_designPixelRatio / pixelRatio);

    // Uzun (narrow) ekranlarda shriftni biroz kamaytir
    final ratioFactor = (aspectRatio / _designRatio * 0.3 + 0.7)
        .clamp(_minFontScale, _maxFontScale);

    return (px * pixelScale * ratioFactor)
        .clamp(px * _minFontScale, px * _maxFontScale);
  }

  // ─── Adaptive funksiyalar (berilgan kenglikka nisbatan) ──────────────────
  //
  // Bu metodlar Flexible, SizedBox, yoki LayoutBuilder ichida
  // ishlaydigan widgetlar uchun mo'ljallangan.
  //
  // Ishlatish tartibi:
  //   1. LayoutBuilder orqali haqiqiy kenglikni ol
  //   2. Uni widget constructoriga o'tkazing
  //   3. Widget ichida context.wOf(px, availableWidth) deb chaqiring
  //
  // Misol:
  //   LayoutBuilder(
  //     builder: (context, constraints) {
  //       return MyWidget(availableWidth: constraints.maxWidth);
  //     },
  //   )
  //
  //   // MyWidget ichida:
  //   padding: EdgeInsets.all(context.wOf(16, widget.availableWidth))

  /// [availableWidth] — LayoutBuilder'dan olingan haqiqiy kenlik
  /// Masalan: Flex(6) da 614px → shu 614px ga nisbatan scale qiladi
  double wOf(double px, double availableWidth) {
    return px * (availableWidth / _designWidth);
  }

  /// [availableWidth] ga moslashtirilgan shrift o'lchami
  /// Pixel ratio va aspect ratio ham hisobga olinadi
  double spOf(double px, double availableWidth) {
    final localBase = availableWidth / _designWidth;
    final pixelScale = localBase * (_designPixelRatio / pixelRatio);

    // availableWidth / screenWidth — bu bo'limning ekrandagi ulushi
    // Shu ulushga qarab aspect ratio'ni hisoblayamiz
    final localAspectRatio = aspectRatio * (availableWidth / screenWidth);
    final ratioFactor = (localAspectRatio / _designRatio * 0.3 + 0.7)
        .clamp(_minFontScale, _maxFontScale);

    return (px * pixelScale * ratioFactor)
        .clamp(px * _minFontScale, px * _maxFontScale);
  }

  // ─── Qator balandligi va harf oralig'i ───────────────────────────────────

  double get lineHeightTight => 1.2;
  double get lineHeightNormal => 1.5;
  double get lineHeightRelaxed => 1.75;

  double get trackingTight => -0.5;
  double get trackingNormal => 0.0;
  double get trackingWide => 0.5;

  // ─── Size getter'lar (to'liq ekran uchun) ────────────────────────────────
  //
  // Adaptive clamp qo'shilgan:
  //   w(px) tablet'da shishib ketmasligi uchun max chegara bilan cheklandi

  double sq(double px) => w(px);

  double get size16 => w(16).clamp(14, 20);
  double get size18 => w(18).clamp(16, 22);
  double get size20 => w(20).clamp(18, 26);
  double get size24 => w(24).clamp(20, 32);
  double get size35 => w(35).clamp(30, 48);
  double get size48 => w(48).clamp(40, 64);
  double get size52 => w(52).clamp(44, 70);
  double get size60 => w(60).clamp(50, 80);

  // ─── Shrift getter'lar (to'liq ekran uchun) ──────────────────────────────

  double get text10 => sp(10);
  double get text12 => sp(12);
  double get text14 => sp(14);
  double get text16 => sp(16);
  double get text18 => sp(18);
  double get text20 => sp(20); 
  double get text22 => sp(22);
  double get text24 => sp(24);
  double get text26 => sp(26);
  double get text28 => sp(28);
  double get text30 => sp(30);
  double get text32 => sp(32);

  // ─── Bo'shliqlar (to'liq ekran uchun) ────────────────────────────────────

  double get spaceXS => w(4).clamp(3, 6);
  double get spaceSM => w(8).clamp(6, 12);
  double get spaceMD => w(12).clamp(10, 16);
  double get spaceLG => w(16).clamp(14, 22);
  double get spaceXL => w(24).clamp(20, 32);
  double get space2XL => w(32).clamp(26, 44);
  double get space3XL => w(48).clamp(40, 64);

  // ─── Ikonkalar ───────────────────────────────────────────────────────────

  double get icon16 => r(16).clamp(14, 20);
  double get icon24 => r(24).clamp(20, 30);
  double get icon32 => r(32).clamp(28, 40);

  // ─── Radiuslar ───────────────────────────────────────────────────────────

  double get radius4 => r(4);
  double get radius8 => r(8);
  double get radius16 => r(16);
  double get radius24 => r(24);
}