import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/auth/auth_ui_feedback.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_up/sections/sign_up_email_widget.dart';
import 'package:halalhub_restaurant/features/restaurant/navigation/post_auth_vendor_navigation.dart';

/// Email orqali ro'yxatdan o'tish: barcha controller va bloc.
mixin SignUpEmailMixin on State<SignUpEmailWidget> {
  static const _vendorRole = 'Vendor';

  late final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isAgreeTerms = ValueNotifier<bool>(false);
  final isAgreeSms = ValueNotifier<bool>(false);

  void onCheckTerms() => isAgreeTerms.value = !isAgreeTerms.value;
  void onCheckSms() => isAgreeSms.value = !isAgreeSms.value;

  void onSubmitSignUpEmail(BuildContext context) {
    if (!isAgreeTerms.value) {
      getIt<Display>().warning(
        TranslationKeys.authMustAcceptTermsPrivacy.tr(context: context),
      );
      return;
    }
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      final err = _firstFieldError();
      if (err != null) getIt<Display>().error(err);
      return;
    }
    context.read<AuthBloc>().add(
          SignUpEmailSubmitted(
            email: emailController.text.trim(),
            firstName: firstNameController.text.trim(),
            lastName: lastNameController.text.trim(),
            password1: passwordController.text,
            password2: confirmPasswordController.text,
            role: _vendorRole,
          ),
        );
  }

  String? _firstFieldError() {
    final invalidFields = formKey.currentState?.validateGranularly();
    if (invalidFields == null || invalidFields.isEmpty) return null;
    return invalidFields.first.errorText;
  }

  void onGoogleSignUp(BuildContext context) {
    context.read<AuthBloc>().add(const LoginGoogleSubmitted());
  }

  void onAppleSignUp(BuildContext context) {
    context.read<AuthBloc>().add(const LoginAppleSubmitted());
  }

  void handleSignUpAuthEffects(
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
      if (successFromAction == AuthPendingAction.resetOtp ||
          successFromAction == AuthPendingAction.verifyOtp) {
        return;
      }
      if (state.message != null) display.success(state.message!);
      context.read<AuthBloc>().add(const AuthReset());
      if (successFromAction == AuthPendingAction.signUpEmail) {
        context.router.push(OtpRoute(emailOrPhone: emailController.text.trim()));
      } else if (successFromAction == AuthPendingAction.loginGoogle ||
          successFromAction == AuthPendingAction.loginApple) {
        navigateAfterLoginCheckingVendor();
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    isAgreeTerms.dispose();
    isAgreeSms.dispose();
    super.dispose();
  }
}
