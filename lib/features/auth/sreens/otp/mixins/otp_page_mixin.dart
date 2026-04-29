import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/auth/auth_ui_feedback.dart';
import 'package:halalhub_restaurant/features/restaurant/navigation/post_auth_vendor_navigation.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/auth/otp_flow.dart';
import 'package:halalhub_restaurant/features/auth/sreens/otp/otp_page.dart';

mixin OtpPageMixin on State<OtpPageBody> {
  void onOtpContinue(BuildContext context, String otp) {
    if (widget.flow == OtpFlow.passwordReset) {
      context.read<AuthBloc>().add(
            PasswordResetOtpVerifySubmitted(
              email: widget.emailOrPhone.trim(),
              otp: otp,
            ),
          );
      return;
    }
    context.read<AuthBloc>().add(
          VerifyOtpSubmitted(
            credential: widget.emailOrPhone,
            otp: otp,
          ),
        );
  }

  void onOtpResend(BuildContext context) {
    if (widget.flow == OtpFlow.passwordReset) {
      context.read<AuthBloc>().add(
            PasswordResetResendSubmitted(email: widget.emailOrPhone.trim()),
          );
      return;
    }
    context.read<AuthBloc>().add(
          ResetOtpRequested(credential: widget.emailOrPhone),
        );
  }

  void handleOtpAuthEffects(
    BuildContext context,
    AuthState state,
    AuthPendingAction? successFromAction, {
    required VoidCallback onResetOtpSucceeded,
  }) {
    final display = getIt<Display>();
    if (state is AuthFailure) {
      showAuthFailureFeedback(context, state);
      context.read<AuthBloc>().add(const AuthReset());
      return;
    }
    if (state is AuthSuccess) {
      if (state.message != null) display.success(state.message!);
      context.read<AuthBloc>().add(const AuthReset());
      if (successFromAction == AuthPendingAction.resetOtp ||
          successFromAction == AuthPendingAction.passwordResetResend) {
        onResetOtpSucceeded();
        return;
      }
      if (successFromAction == AuthPendingAction.verifyOtp) {
        if (widget.flow == OtpFlow.account) {
          navigateAfterLoginCheckingVendor();
        }
        return;
      }
      if (successFromAction == AuthPendingAction.passwordResetOtpVerify &&
          widget.flow == OtpFlow.passwordReset) {
        context.router.push(const ResetPasswordRoute());
        return;
      }
    }
  }
}
