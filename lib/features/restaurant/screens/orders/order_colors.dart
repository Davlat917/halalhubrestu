import 'package:flutter/material.dart';

/// Buyurtmalar ekrani dizayn tokenlari.
abstract class OrderColors {
  static const success = Color(0xFF21A344);
  static const actionBlue = Color(0xFF0088FF);
  static const warningOrange = Color(0xFFFFB000);
  static const danger = Color(0xFFFF6B6B);
  static const track = Color(0xFFE0E0E0);
  static const newBadgeBg = Color(0xFFE3F2FD);
  static const acceptedBadgeBg = Color(0xFFFFF8E1);
  static const readyBadgeBg = Color(0xFFE8F5E9);
  /// Yakuniy «Done» tugmasi foni.
  static const doneStripBg = Color(0xFFE8F5E9);
  /// Yakuniy «Canceled» tugmasi foni.
  static const canceledStripBg = Color(0xFFFFEBEE);
  /// Yetkazib bo‘lmagan buyurtma chizig‘i foni.
  static const deliveryFailedStripBg = Color(0xFFFFF3E0);
}
