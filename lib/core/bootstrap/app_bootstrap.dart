import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:halalhub_restaurant/firebase_options.dart';

/// Ilova ishga tushishidan oldingi bir martalik sozlamalar (Firebase va hokazo).
abstract final class AppBootstrap {
  AppBootstrap._();

  /// [WidgetsFlutterBinding.ensureInitialized] va [Firebase.initializeApp].
  /// `flutterfire configure` bilan yaratilgan [DefaultFirebaseOptions] ishlatiladi.
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
