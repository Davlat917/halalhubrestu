// lib/mixins/validation_mixin.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';

mixin ValidationMixin {
  static final RegExp _paymentEinRegex = RegExp(r'^\d{2}-\d{7}$');
  static final RegExp _paymentDigitsOnlyRegex = RegExp(r'^\d+$');

  // ══════════════════════════════════════════
  //  FORM FIELD VALIDATION
  // ══════════════════════════════════════════

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.validationEmailRequired.tr();
    }
    final regex = RegExp(r'^[\w.-]+@[\w.-]+\.\w{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return TranslationKeys.validationEmailInvalid.tr();
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return TranslationKeys.validationPasswordRequired.tr();
    }
    if (value.length < 8) {
      return TranslationKeys.validationPasswordMinLength.tr();
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return TranslationKeys.validationPasswordUppercase.tr();
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return TranslationKeys.validationPasswordNumber.tr();
    }
    return null;
  }

  String? validateConfirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return TranslationKeys.validationConfirmPasswordRequired.tr();
    }
    if (value != original) {
      return TranslationKeys.validationPasswordMismatch.tr();
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.validationPhoneRequired.tr();
    }
    final cleaned = value.replaceAll(RegExp(r'[\s\-()\.]'), '');
    final international = RegExp(r'^\+[1-9]\d{6,14}$');
    final local = RegExp(r'^[0-9]{9,12}$');
    if (!international.hasMatch(cleaned) && !local.hasMatch(cleaned)) {
      return TranslationKeys.validationPhoneFormatExample.tr();
    }
    return null;
  }

  /// AQSh: +1 va NANP 10 raqam (maska `+1(###) ###-##-##`).
  String? validateUsPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.validationPhoneRequired.tr();
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11 || !digits.startsWith('1')) {
      return TranslationKeys.validationUsPhoneOnly.tr();
    }
    final nanp = digits.substring(1);
    final a = nanp.codeUnitAt(0) - 48;
    final d = nanp.codeUnitAt(3) - 48;
    if (a < 2 || a > 9 || d < 2 || d > 9) {
      return TranslationKeys.validationUsPhoneInvalid.tr();
    }
    return null;
  }

  String? validateName(String? value, {int min = 2}) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.validationNameRequired.tr();
    }
    if (value.trim().length < min) {
      return TranslationKeys.validationNameMin.tr(namedArgs: {'min': '$min'});
    }
    if (value.contains(RegExp(r'[0-9]'))) {
      return TranslationKeys.validationNameNoNumbers.tr();
    }
    return null;
  }

  String? validateRequired(String? value, {String field = 'Maydon'}) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.validationFieldMustNotBeEmpty.tr(
        namedArgs: {'field': field},
      );
    }
    return null;
  }

  String? validateBusinessNameForPayment(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return TranslationKeys.validationBusinessNameRequired.tr();
    }
    if (text.length > 255) {
      return TranslationKeys.validationBusinessNameTooLong.tr();
    }
    return null;
  }

  String? validateEinForPayment(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return TranslationKeys.validationEinRequired.tr();
    if (!_paymentEinRegex.hasMatch(text)) {
      return TranslationKeys.validationEinFormat.tr();
    }
    return null;
  }

  String? validatePaymentDigitsField(
    String? value, {
    required String fieldName,
    int? exactLength,
    int maxLength = 50,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return TranslationKeys.validationFieldRequired.tr(
        namedArgs: {'field': fieldName},
      );
    }
    if (!_paymentDigitsOnlyRegex.hasMatch(text)) {
      return TranslationKeys.validationFieldDigitsOnly.tr(
        namedArgs: {'field': fieldName},
      );
    }
    if (exactLength != null && text.length != exactLength) {
      return TranslationKeys.validationTooShort.tr();
    }
    if (text.length > maxLength) {
      return TranslationKeys.validationFieldTooLong.tr(
        namedArgs: {'field': fieldName},
      );
    }
    return null;
  }

  // ══════════════════════════════════════════
  //  BUSINESS LOGIC VALIDATION
  // ══════════════════════════════════════════

  String? validateNumber(String? value, {double? min, double? max}) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.validationNumberRequired.tr();
    }
    final num = double.tryParse(value);
    if (num == null) return TranslationKeys.validationOnlyNumbers.tr();
    if (min != null && num < min) {
      return TranslationKeys.validationMinValue.tr(namedArgs: {'min': '$min'});
    }
    if (max != null && num > max) {
      return TranslationKeys.validationMaxValue.tr(namedArgs: {'max': '$max'});
    }
    return null;
  }

  String? validatePrice(String? value) {
    return validateNumber(value, min: 0.01, max: 999_999_999);
  }

  String? validateDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.validationDateRequired.tr();
    }
    final date = DateTime.tryParse(value);
    if (date == null) return TranslationKeys.validationDateFormat.tr();
    return null;
  }

  String? validateDateRange(DateTime? from, DateTime? to) {
    if (from == null || to == null) {
      return TranslationKeys.validationDateRangeRequired.tr();
    }
    if (to.isBefore(from)) {
      return TranslationKeys.validationDateRangeInvalid.tr();
    }
    return null;
  }

  // ══════════════════════════════════════════
  //  API RESPONSE VALIDATION
  // ══════════════════════════════════════════

  bool isApiResponseValid(Map<String, dynamic>? response) {
    if (response == null) return false;
    return response.containsKey('data') && response['data'] != null;
  }

  String getApiError(Map<String, dynamic>? response, {String fallback = ''}) {
    final resolvedFallback = fallback.isEmpty
        ? TranslationKeys.errorOccurredTitle.tr()
        : fallback;
    if (response == null) return resolvedFallback;
    return response['message']?.toString() ??
        response['error']?.toString() ??
        resolvedFallback;
  }

  bool isStatusSuccess(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  T? safeGet<T>(Map<String, dynamic>? map, String key) {
    if (map == null || !map.containsKey(key)) return null;
    final value = map[key];
    return value is T ? value : null;
  }
}
