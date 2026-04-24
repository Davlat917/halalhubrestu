import 'package:another_flushbar/flushbar.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/core/widgets/display/display_type.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';
import 'package:flutter/material.dart';

class DisplayInitializer {
  DisplayInitializer._();
  static void init({required GlobalKey<NavigatorState> navigatorKey}) {
    getIt<Display>().setOnDisplayListener((message) {
      final context = navigatorKey.currentContext;
      if (context == null) return;
      final Widget icon;
      final Color color;

      switch (message.type) {
        case DisplayType.error:
          icon = Assets.icons.information.svg(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            height: 28,
            width: 28, //
          );
          color = Colors.red;
          break;
        case DisplayType.warning:
          icon = Assets.icons.information.svg(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            height: 28,
            width: 28, //
          );
          color = Colors.orange;
          break;
        case DisplayType.info:
          icon = Assets.icons.information.svg(
            colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            height: 28,
            width: 28, //
          );
          color = Colors.blue;
          break;
        case DisplayType.success:
          icon = Assets.images.verify.image(
            color: Colors.white,
            height: 28,
            width: 28, //
          );
          color = Colors.green;
          break;
      }

      final screenWidth = MediaQuery.of(context).size.width;
      final isTablet = screenWidth >= 600;

      Flushbar(
        margin: const EdgeInsets.all(16),
        borderRadius: BorderRadius.circular(8),
        backgroundColor: color,
        flushbarPosition: FlushbarPosition.TOP,
        message: message.description,
        icon: icon,
        maxWidth: isTablet ? 500 : null,
        // ─── Animatsiya ───────────────────────────────────────────────────
        // Tepadan tushish: tez tushadi, pastga o'tib (bounce), qaytadi
        animationDuration: const Duration(milliseconds: 700),
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,

        // Ekranda turish vaqti (bounce tugagandan keyin)
        duration: const Duration(seconds: 2),
      ).show(context);
    });
  }
}
