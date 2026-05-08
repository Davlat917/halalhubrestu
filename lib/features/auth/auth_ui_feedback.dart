import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/core/widgets/feedback/global_feedback_dialog.dart';
import 'package:halalhub_restaurant/features/auth/auth_error_ui.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/navigation/post_auth_vendor_navigation.dart';

/// Email / Google / Apple bilan kirish muvaffaqiyatida `/vendors/me/` tekshiriladi (profil yoki restoran yaratish).
/// Boshqa auth ekranlari ([AuthPendingAction.signUpEmail] va h.k.) o‘z listenerlarida boshqariladi.
void handleSignInFlowResult(
  BuildContext context,
  AuthState state,
  AuthPendingAction? successFromAction,
) {
  final display = getIt<Display>();
  if (state is AuthFailure) {
    showAuthFailureFeedback(context, state);
    context.read<AuthBloc>().add(const AuthReset());
    return;
  }
  if (state is AuthSuccess) {
    if (successFromAction != AuthPendingAction.loginEmail &&
        successFromAction != AuthPendingAction.loginGoogle &&
        successFromAction != AuthPendingAction.loginApple) {
      return;
    }
    if (state.message != null) {
      display.success(state.message!);
    }
    context.read<AuthBloc>().add(const AuthReset());
    // Root `replace` bilan AuthFlow o‘chirilguncha bir freym kutamiz — element daraxti sinxronida.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      unawaited(navigateAfterLoginCheckingVendor());
    });
  }
}

void showAuthFailureFeedback(BuildContext context, AuthFailure state) {
  if (!context.mounted) return;
  final message = authErrorUserMessage(state.exception);
  showGlobalFailureFeedback(
    context,
    message: message,
    title: TranslationKeys.errorOccurredTitle.tr(context: context),
  );
}
