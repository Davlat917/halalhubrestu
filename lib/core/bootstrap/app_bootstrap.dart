import 'package:firebase_core/firebase_core.dart';
import 'package:halalhub_restaurant/firebase_options.dart';

/// Ilova ishga tushishidan oldingi bir martalik sozlamalar (Firebase va hokazo).
abstract final class AppBootstrap {
  AppBootstrap._();

  /// [Firebase.initializeApp] — [WidgetsFlutterBinding.ensureInitialized] allaqachon [main] da.
  /// `flutterfire configure` bilan yaratilgan [DefaultFirebaseOptions] ishlatiladi.
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
