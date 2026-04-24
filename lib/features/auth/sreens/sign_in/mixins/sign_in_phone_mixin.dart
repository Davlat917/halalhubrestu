import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/auth/auth_ui_feedback.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_in/widgets/sign_in_phone_widget.dart';
import 'package:halalhub_restaurant/features/restaurant/navigation/post_auth_vendor_navigation.dart';

mixin SignInPhoneMixin on State<SignInPhoneWidget> {
  static const _vendorRole = 'Vendor';

  late final formKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  void onSubmitSignInPhone(BuildContext context) {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      final err = _firstFieldError();
      if (err != null) getIt<Display>().error(err);
      return;
    }
    final raw = phoneController.text.replaceAll(RegExp(r'[^\d+]'), '');
    context.read<AuthBloc>().add(
          SignUpPhoneSubmitted(
            phoneNumber: raw,
            role: _vendorRole,
          ),
        );
  }

  String? _firstFieldError() {
    final invalidFields = formKey.currentState?.validateGranularly();
    if (invalidFields == null || invalidFields.isEmpty) return null;
    return invalidFields.first.errorText;
  }

  void onGoogleSignIn(BuildContext context) {
    context.read<AuthBloc>().add(const LoginGoogleSubmitted());
  }

  void onAppleSignIn(BuildContext context) {
    context.read<AuthBloc>().add(const LoginAppleSubmitted());
  }

  /// Telefon: OTP ga; Google/Apple: mahsulotlar (sign-in home).
  void handleSignInPhoneTabAuthEffects(
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
      // OTP sahifasi (resend / verify) o'z listenerida boshqaradi; stackdagi SignIn tab
      // hali mount bo'lsa ham bu yerda navigatsiya qilmaslik kerak.
      if (successFromAction == AuthPendingAction.resetOtp ||
          successFromAction == AuthPendingAction.verifyOtp ||
          successFromAction == AuthPendingAction.signUpEmail ||
          successFromAction == AuthPendingAction.loginEmail ||
          successFromAction == AuthPendingAction.passwordResetRequest ||
          successFromAction == AuthPendingAction.passwordResetResend ||
          successFromAction == AuthPendingAction.passwordResetOtpVerify) {
        return;
      }
      if (state.message != null) display.success(state.message!);
      context.read<AuthBloc>().add(const AuthReset());
      if (successFromAction == AuthPendingAction.signUpPhone) {
        context.router.push(OtpRoute(emailOrPhone: phoneController.text.trim()));
      } else {
        navigateAfterLoginCheckingVendor();
      }
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
