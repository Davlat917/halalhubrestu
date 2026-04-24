import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/auth/auth_ui_feedback.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_in/widgets/sign_in_email_widget.dart';

/// Email bilan kirish: forma, validatsiya, bloc chaqiruvlari — UI `SignInEmailWidget` da.
/// `State` `ValidationMixin` bilan birga qo‘llanishi kerak.
mixin SignInEmailMixin on State<SignInEmailWidget> {
  late final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void onSubmitEmail(BuildContext context) {
    final formState = formKey.currentState;
    if (formState == null) return;
    if (!formState.validate()) {
      final firstError = _firstFieldError();
      if (firstError != null) {
        getIt<Display>().error(firstError);
      }
      return;
    }
    context.read<AuthBloc>().add(
          LoginEmailSubmitted(
            email: emailController.text.trim(),
            password: passwordController.text,
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

  void handleSignInAuthEffects(
    BuildContext context,
    AuthState state,
    AuthPendingAction? successFromAction,
  ) {
    handleSignInFlowResult(context, state, successFromAction);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
