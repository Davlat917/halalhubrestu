import 'dart:async';

// import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:halalhub_restaurant/app/app.dart';
import 'package:halalhub_restaurant/core/bootstrap/app_bootstrap.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/storage/storage.dart';
import 'package:halalhub_restaurant/features/restaurant/services/push_notification_service.dart';

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  binding.deferFirstFrame();
  if (kDebugMode) debugPrint('[main] deferFirstFrame enabled');

  await AppBootstrap.initialize();
  await configureDependencies();

  // FCM ni ilovani bloklamasdan ishga tushiramiz.
  // Xato yuz bersa log chiqaramiz, ilovani crash qilmaymiz.
  unawaited(
    PushNotificationService.initialize().catchError(
      (Object e, StackTrace st) =>
          kDebugMode ? debugPrint('[main] PushNotificationService error: $e\n$st') : null,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const _Root(), //
  );
}

class _Root extends StatelessWidget {
  const _Root();

  static const Locale _enLocale = Locale('en', 'US');
  static const Locale _uzLocale = Locale('uz', 'UZ');
  static const Locale _arLocale = Locale('ar', 'SA');
  static const Locale _ruLocale = Locale('ru', 'RU');

  Locale _resolveStartLocale() {
    final code = getIt<Storage>().languageCode.call()?.trim().toLowerCase();
    // Foydalanuvchi tilni tanlamaguncha (storage bo'sh) — inglizcha.
    if (code == null || code.isEmpty) {
      return _enLocale;
    }
    switch (code) {
      case 'en':
        return _enLocale;
      case 'ar':
        return _arLocale;
      case 'ru':
        return _ruLocale;
      case 'uz':
        return _uzLocale;
      default:
        return _enLocale;
    }
  }

  @override
  Widget build(BuildContext context) {
    final startLocale = _resolveStartLocale();
    return EasyLocalization(
      supportedLocales: const [_enLocale, _uzLocale, _arLocale, _ruLocale],
      path: 'assets/locales',
      startLocale: startLocale,
      fallbackLocale: _enLocale,
      saveLocale: true,
      child: const App(), //
      // child: DevicePreview(
      //   enabled: kDebugMode,
      //   builder: (_) {
      //     return const App();
      //   },
      // ),
    );
  }
}
