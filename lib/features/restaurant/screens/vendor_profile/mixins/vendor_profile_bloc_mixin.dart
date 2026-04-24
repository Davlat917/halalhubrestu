import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/widgets/feedback/global_feedback_dialog.dart';
import 'package:halalhub_restaurant/features/restaurant/bloc/vendor_profile/vendor_profile_bloc.dart';

/// Bloc holatiga qarab foydalanuvchiga xabar (faqat UI reaksiya — ma'lumot blocdan).
mixin VendorProfileBlocMixin {
  void onVendorProfileListen(BuildContext context, VendorProfileState state) {
    if (state is VendorProfileFailure) {
      showGlobalFailureFeedback(
        context,
        message: state.exception.message,
        title: TranslationKeys.profileLoadFailedTitle.tr(context: context),
      );
    }
  }
}
