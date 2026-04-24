import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';

mixin UpdateRestaurantValidationMixin {
  String? validateRequired(String? value, {required String field}) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.validationFieldRequired.tr(
        namedArgs: {'field': field},
      );
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty)
      return TranslationKeys.validationEmailRequired.tr();
    final v = value.trim();
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v)) {
      return TranslationKeys.validationEmailInvalid.tr();
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return TranslationKeys.validationRestaurantNameRequired.tr();
    }
    if (value.trim().length < 2) return TranslationKeys.validationTooShort.tr();
    return null;
  }

  String? validateUsPhone(String? value) {
    if (value == null || value.trim().isEmpty)
      return TranslationKeys.validationPhoneRequired.tr();
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return TranslationKeys.validationPhoneInvalid.tr();
    return null;
  }

  Future<TimeOfDay?> pickTime(BuildContext context, TimeOfDay initial) {
    return showTimePicker(
      context: context,
      initialTime: initial,
      initialEntryMode: TimePickerEntryMode.input,
    );
  }
}
