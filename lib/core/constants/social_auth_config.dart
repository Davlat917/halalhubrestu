import 'dart:io' show Platform;

/// [google_sign_in ^7](https://pub.dev/packages/google_sign_in) va
/// [google_sign_in_ios](https://pub.dev/packages/google_sign_in_ios) bo‘yicha sozlash.
///
/// **iOS:** `GoogleService-Info.plist` dagi **CLIENT_ID** (iOS OAuth client) kerak.
/// Variantlar:
/// 1) `ios/Runner/Info.plist` ichida `GIDClientID` + `CFBundleURLTypes` (`REVERSED_CLIENT_ID`)
/// 2) yoki build: `--dart-define=GOOGLE_IOS_CLIENT_ID=....apps.googleusercontent.com`
///
/// **Android:** `android/app/google-services.json` tavsiya etiladi; bo‘lmasa
/// [serverClientId] (Web client) bilan `initialize` ishlashi kerak.
class SocialAuthConfig {
  SocialAuthConfig._();

  /// iOS OAuth client ID (Firebase / Google Cloud → iOS ilova).
  static const String _iosClientIdEnv = String.fromEnvironment(
    'GOOGLE_IOS_CLIENT_ID',
    defaultValue: '',
  );

  /// Google Cloud Console → APIs & Services → Credentials → **OAuth 2.0 Client IDs → iOS**
  /// (Web client ID emas; `810092682000-....` kabi web ID ni bu yerga yozmang).
  ///
  /// Bo‘sh qoldirilsa: `ios/Runner/GoogleService-Info.plist` ichidagi `CLIENT_ID` yoki
  /// `Info.plist` dagi `GIDClientID` ishlatiladi — lekin ular ham bo‘lmasa xato chiqadi.
  static const String iosOAuthClientIdEmbedded = '';

  /// Web (server) OAuth client ID — backend Google token almashinuvi uchun.
  static const String serverClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
    defaultValue: '810092682000-5m2cdd92gv7nfetchtc0h1vnll2s89ga.apps.googleusercontent.com',
  );

  /// `GoogleSignIn.initialize(clientId: ...)` uchun iOS client ID.
  ///
  /// Ustunlik: `--dart-define=GOOGLE_IOS_CLIENT_ID=...` → [iosOAuthClientIdEmbedded] →
  /// `null` (native `GoogleService-Info.plist` / `Info.plist` ga ishora).
  static String? get googleClientId {
    if (!Platform.isIOS) return null;
    final fromEnv = _iosClientIdEnv.trim();
    if (fromEnv.isNotEmpty) return fromEnv;
    final embedded = iosOAuthClientIdEmbedded.trim();
    if (embedded.isNotEmpty) return embedded;
    return null;
  }
}
