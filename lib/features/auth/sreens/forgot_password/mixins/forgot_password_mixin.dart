import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/auth/auth_ui_feedback.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/auth/otp_flow.dart';
import 'package:halalhub_restaurant/features/auth/password_reset_session.dart';
import 'package:halalhub_restaurant/features/auth/sreens/forgot_password/widgets/forgot_password_card_widget.dart';

mixin ForgotPasswordMixin on State<ForgotPasswordCardWidget> {
  late final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

  void onSubmitForgotPassword(BuildContext context) {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      final err = _firstError();
      if (err != null) getIt<Display>().error(err);
      return;
    }
    context.read<AuthBloc>().add(
          PasswordResetRequestSubmitted(email: emailController.text.trim()),
        );
  }

  String? _firstError() {
    final invalidFields = formKey.currentState?.validateGranularly();
    if (invalidFields == null || invalidFields.isEmpty) return null;
    return invalidFields.first.errorText;
  }

  void handleForgotPasswordEffects(BuildContext context, AuthState state) {
    final display = getIt<Display>();
    if (state is AuthFailure) {
      showAuthFailureFeedback(context, state);
      context.read<AuthBloc>().add(const AuthReset());
      return;
    }
    if (state is AuthSuccess) {
      final email = emailController.text.trim();
      PasswordResetSession.pendingEmail = email;
      PasswordResetSession.pendingResetToken = null;
      if (state.message != null) display.success(state.message!);
      context.read<AuthBloc>().add(const AuthReset());
      context.router.push(
        OtpRoute(emailOrPhone: email, flow: OtpFlow.passwordReset),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
