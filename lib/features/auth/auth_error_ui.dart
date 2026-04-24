import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';

/// API xatoliklari: 4xx va tushunarli matn — dialog; 5xx, HTML, umumiy server — oddiy inglizcha flushbar.
bool authErrorPreferDialog(NetworkException e) {
  if (e is! ServerException) return false;
  final code = e.statusCode ?? 0;
  if (code >= 500) return false;
  final m = e.message.trim();
  if (m.isEmpty || m == TranslationKeys.networkServerError.tr()) return false;
  if (m.contains('<')) return false;
  if (m.length > 400) return false;
  return true;
}

String authErrorUserMessage(NetworkException e) {
  if (authErrorPreferDialog(e)) return e.message;
  if (e is ServerException && (e.statusCode ?? 0) >= 500) {
    return TranslationKeys.commonSomethingWentWrongTryAgain.tr();
  }
  final m = e.message.trim();
  if (m.contains('<')) {
    return TranslationKeys.commonSomethingWentWrongTryAgain.tr();
  }
  if (m == TranslationKeys.networkServerError.tr()) {
    return TranslationKeys.commonSomethingWentWrongTryAgain.tr();
  }
  return m;
}
