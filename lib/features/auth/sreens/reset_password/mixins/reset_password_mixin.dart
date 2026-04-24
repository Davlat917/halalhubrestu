import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/auth/auth_ui_feedback.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/auth/password_reset_session.dart';
import 'package:halalhub_restaurant/features/auth/sreens/reset_password/widgets/reset_password_card_widget.dart';

mixin ResetPasswordMixin on State<ResetPasswordCardWidget> {
  late final formKey = GlobalKey<FormState>();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void onSubmitResetPassword(BuildContext context) {
    final token = PasswordResetSession.pendingResetToken;
    if (token == null || token.isEmpty) {
      getIt<Display>().error(
        TranslationKeys.authCompleteVerificationStepFirst.tr(
          context: context,
        ),
      );
      return;
    }
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      final err = _firstError();
      if (err != null) getIt<Display>().error(err);
      return;
    }
    context.read<AuthBloc>().add(
          PasswordResetConfirmSubmitted(
            resetToken: token,
            newPassword: passwordController.text,
          ),
        );
  }

  String? _firstError() {
    final invalidFields = formKey.currentState?.validateGranularly();
    if (invalidFields == null || invalidFields.isEmpty) return null;
    return invalidFields.first.errorText;
  }

  void handleResetPasswordEffects(BuildContext context, AuthState state) {
    final display = getIt<Display>();
    if (state is AuthFailure) {
      showAuthFailureFeedback(context, state);
      context.read<AuthBloc>().add(const AuthReset());
      return;
    }
    if (state is AuthSuccess) {
      PasswordResetSession.clear();
      if (state.message != null) display.success(state.message!);
      context.read<AuthBloc>().add(const AuthReset());
      _goToSignIn();
    }
  }

  void _goToSignIn() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<AppRouter>().replaceAll([
        const AuthFlowRoute(children: [SignInRoute()]),
      ]);
    });
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
