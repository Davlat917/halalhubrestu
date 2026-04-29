import 'dart:async';
import 'dart:io' show Platform;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/constants/social_auth_config.dart';
import 'package:halalhub_restaurant/features/auth/data/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

@lazySingleton
class SocialAuth {
  SocialAuth(this.authRepo);

  final AuthRepository authRepo;

  static const _googleScopes = <String>['email', 'profile', 'openid'];

  StreamSubscription<GoogleSignInAuthenticationEvent>? _googleAuthSubscription;
  Future<void>? _googleInitFuture;

  /// [google_sign_in 7.x](https://pub.dev/packages/google_sign_in): bir marta `initialize`.
  Future<void> _ensureGoogleInitialized() {
    _googleInitFuture ??= () async {
      final signIn = GoogleSignIn.instance;
      await signIn.initialize(
        clientId: SocialAuthConfig.googleClientId,
        serverClientId: SocialAuthConfig.serverClientId,
      );
      if (kDebugMode) {
        final id = SocialAuthConfig.googleClientId;
        final src = id == null
            ? 'native plist (GoogleService-Info CLIENT_ID / Info.plist GIDClientID)'
            : 'dart-define or iosOAuthClientIdEmbedded';
        debugPrint('[GoogleSignIn] initialized (iOS clientId from $src)');
      }
    }();
    return _googleInitFuture!;
  }

  /// Google: faqat OAuth access token → backend (`loginWithGoogle`).
  /// Firebase ishlatilmaydi (loyihada `Firebase.initializeApp` yo‘q edi).
  Future<Map<String, String?>> signInWithGoogleFirebase() async {
    final userData = <String, String?>{
      'id': null,
      'email': null,
      'displayName': null,
      'idToken': null,
      'accessToken': null,
      'errorMessage': null,
      'uid': null,
    };

    try {
      await _ensureGoogleInitialized();
      final signIn = GoogleSignIn.instance;

      final completer = Completer<GoogleSignInAccount?>();
      _googleAuthSubscription = signIn.authenticationEvents.listen(
        (event) {
          if (completer.isCompleted) return;
          if (event is GoogleSignInAuthenticationEventSignIn) {
            completer.complete(event.user);
          } else if (event is GoogleSignInAuthenticationEventSignOut) {
            completer.complete(null);
          }
        },
        onError: (Object e) {
          if (!completer.isCompleted) {
            completer.completeError(e);
          }
        },
      );

      await signIn.authenticate();

      final GoogleSignInAccount? account = await completer.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () => null,
      );
      await _googleAuthSubscription?.cancel();
      _googleAuthSubscription = null;

      if (account == null) {
        userData['errorMessage'] = TranslationKeys.authSignInCancelled.tr();
        return userData;
      }

      final GoogleSignInClientAuthorization clientAuth = await account
          .authorizationClient
          .authorizeScopes(_googleScopes);

      final String accessToken = clientAuth.accessToken;
      if (accessToken.isEmpty) {
        userData['errorMessage'] = TranslationKeys.authGoogleAccessTokenMissing
            .tr();
        return userData;
      }

      try {
        await authRepo.loginWithGoogle(accessToken: accessToken);
        await authRepo.updateRole();
      } catch (e) {
        userData['errorMessage'] = TranslationKeys.authCouldNotCompleteSignIn
            .tr(namedArgs: {'error': '$e'});
        return userData;
      }

      userData['accessToken'] = accessToken;
      userData['email'] = account.email;
      userData['displayName'] = account.displayName;
      if (kDebugMode) debugPrint('✅ [Google] OK ${account.email}');
    } on TimeoutException {
      userData['errorMessage'] = TranslationKeys.authRequestTimedOut.tr();
    } on GoogleSignInException catch (e) {
      if (kDebugMode) debugPrint('❌ [Google] ${e.code} — ${e.description}');
      userData['errorMessage'] = switch (e.code) {
        GoogleSignInExceptionCode.canceled =>
          TranslationKeys.authSignInCancelled.tr(),
        GoogleSignInExceptionCode.clientConfigurationError =>
          _googleConfigHint(),
        _ => TranslationKeys.authGoogleError.tr(
          namedArgs: {'error': e.description ?? ''},
        ),
      };
    } catch (e, st) {
      if (kDebugMode) debugPrint('❌ [Google] $e\n$st');
      userData['errorMessage'] = TranslationKeys.authErrorPrefix.tr(
        namedArgs: {'error': '$e'},
      );
    } finally {
      await _googleAuthSubscription?.cancel();
      _googleAuthSubscription = null;
    }

    return userData;
  }

  String _googleConfigHint() {
    if (Platform.isIOS) {
      return TranslationKeys.authGoogleIosNotConfigured.tr();
    }
    return TranslationKeys.authGoogleConfigError.tr();
  }

  Future<Map<String, String?>> signInWithApple() async {
    final userData = <String, String?>{
      'email': null,
      'displayName': null,
      'errorMessage': null,
    };

    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        userData['errorMessage'] = TranslationKeys.authAppleUnavailable.tr();
        return userData;
      }

      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final String idToken = appleCredential.identityToken ?? '';
      final String authCode = appleCredential.authorizationCode;

      if (idToken.isEmpty) {
        userData['errorMessage'] = TranslationKeys.authAppleIdentityTokenMissing
            .tr();
        return userData;
      }

      try {
        await authRepo.loginWithApple(
          accessToken: idToken,
          code: authCode,
          idToken: idToken,
        );

        userData['email'] = appleCredential.email;
        userData['displayName'] =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();

        try {
          await authRepo.updateRole();
        } catch (e) {
          if (kDebugMode) debugPrint('updateRole: $e');
        }
      } catch (e) {
        userData['errorMessage'] = TranslationKeys.authCouldNotCompleteSignIn
            .tr(namedArgs: {'error': '$e'});
        return userData;
      }

      return userData;
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        userData['errorMessage'] = TranslationKeys.authSignInCancelled.tr();
      } else {
        userData['errorMessage'] = TranslationKeys.authAppleSignInError.tr(
          namedArgs: {'error': e.message},
        );
      }
    } catch (error) {
      userData['errorMessage'] = TranslationKeys.authErrorPrefix.tr(
        namedArgs: {'error': '$error'},
      );
      if (kDebugMode) debugPrint('❌ [Apple] $error');
    }

    return userData;
  }
}
