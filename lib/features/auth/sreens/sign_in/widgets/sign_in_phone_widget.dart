import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/mixins/validation_mixin.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/auth/auth_listen_when.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_in/mixins/sign_in_phone_mixin.dart';

class SignInPhoneWidget extends StatefulWidget {
  final double? availableWidth;
  final double? buttonHeight;
  const SignInPhoneWidget({super.key, this.availableWidth, this.buttonHeight});

  @override
  State<SignInPhoneWidget> createState() => _SignInPhoneWidgetState();
}

class _SignInPhoneWidgetState extends State<SignInPhoneWidget>
    with ValidationMixin, SignInPhoneMixin {
  AuthPendingAction? _successFromAction;

  @override
  Widget build(BuildContext context) {
    final aW = widget.availableWidth ?? context.screenWidth;
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) {
        if (c is AuthFailure) {
          if (authFailureShouldBeHandledOnlyOnOtpPage(p)) return false;
          _successFromAction = null;
          return true;
        }
        if (c is AuthSuccess && p is AuthLoading) {
          _successFromAction = p.action;
          return true;
        }
        return false;
      },
      listener: (context, state) =>
          handleSignInPhoneTabAuthEffects(context, state, _successFromAction),
      builder: (context, state) {
        final busy = state is AuthLoading;
        final pending = state is AuthLoading ? state.action : null;
        final phoneBusy = pending == AuthPendingAction.signUpPhone;
        // final googleBusy = pending == AuthPendingAction.loginGoogle;
        // final appleBusy = pending == AuthPendingAction.loginApple;
        return Form(
          key: formKey,
          child: Column(
            spacing: context.wOf(16, aW),
            children: [
              CommonTextField(
                controller: phoneController,
                availableWidth: aW,
                keyboardType: TextInputType.phone,
                hint: TranslationKeys.authPhoneMask.tr(context: context),
                mask: '+1(###) ###-##-##',
                validator: validateUsPhone,
              ),
              CustomButton(
                height: widget.buttonHeight ?? context.wOf(48, aW),
                textStyle: AppTextStyle.regular16(
                  context,
                  color: StaticColors.primary,
                  aW: aW,
                ),
                label: TranslationKeys.continueText.tr(context: context),
                isLoading: phoneBusy,
                onPressed: busy ? null : () => onSubmitSignInPhone(context),
              ),
              Row(
                spacing: 16,
                children: [
                  Expanded(child: Divider(color: StaticColors.cD9D9D9)),
                  Text(
                    TranslationKeys.or.tr(context: context),
                    style: AppTextStyle.regular14(
                      context,
                      color: StaticColors.cBDC1C6,
                      aW: aW,
                    ),
                  ),
                  Expanded(child: Divider(color: StaticColors.cD9D9D9)),
                ],
              ),
              CustomButton(
                height: widget.buttonHeight ?? context.wOf(48, aW),
                backgroundColor: StaticColors.backgroundColor,
                foregroundColor: StaticColors.primary,
                textStyle: AppTextStyle.regular16(context, aW: aW),
                label: TranslationKeys.createAccount.tr(context: context),
                onPressed: () => context.router.push(const SignUpRoute()),
              ),
              // CustomButton(
              //   borderRadius: 30,
              //   suffixIcon: Assets.icons.appleIcon.svg(),
              //   height: widget.buttonHeight ?? context.wOf(48, aW),
              //   backgroundColor: StaticColors.backgroundColor,
              //   foregroundColor: StaticColors.primary,
              //   textStyle: AppTextStyle.regular16(context, aW: aW),
              //   label: 'Sign in with Apple',
              //   isLoading: appleBusy,
              //   onPressed: busy ? null : () => onAppleSignIn(context),
              // ),
              // CustomButton(
              //   borderRadius: 30,
              //   suffixIcon: Assets.icons.googleIcon.svg(),
              //   height: widget.buttonHeight ?? context.wOf(48, aW),
              //   backgroundColor: StaticColors.backgroundColor,
              //   foregroundColor: StaticColors.primary,
              //   textStyle: AppTextStyle.regular16(context, aW: aW),
              //   label: 'Sign in with Google',
              //   isLoading: googleBusy,
              //   onPressed: busy ? null : () => onGoogleSignIn(context),
              // ),
            ],
          ),
        );
      },
    );
  }
}
