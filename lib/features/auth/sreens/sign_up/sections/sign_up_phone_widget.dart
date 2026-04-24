import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/mixins/validation_mixin.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/auth/auth_listen_when.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_up/mixins/sign_up_phone_mixin.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_up/widgets/agree_terms_widget.dart';
// import 'package:halalhub_restaurant/gen/assets.gen.dart';

class SignUpPhoneWidget extends StatefulWidget {
  final double? availableWidth;
  final double? buttonHeight;
  const SignUpPhoneWidget({super.key, this.availableWidth, this.buttonHeight});

  @override
  State<SignUpPhoneWidget> createState() => _SignUpPhoneWidgetState();
}

class _SignUpPhoneWidgetState extends State<SignUpPhoneWidget> with ValidationMixin, SignUpPhoneMixin {
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
      listener: (context, state) => handleSignUpPhoneAuthEffects(context, state, _successFromAction),
      builder: (context, state) {
        final busy = state is AuthLoading;
        final pending = state is AuthLoading ? state.action : null;
        final signUpBusy = pending == AuthPendingAction.signUpPhone;
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
              ValueListenableBuilder(
                valueListenable: isAgreeTerms,
                builder: (context, value, child) {
                  return AgreeTermsWidget(
                    availableWidth: widget.availableWidth,
                    isAgree: value,
                    onPressed: onCheckTerms,
                    showVendorLegalLinks: true,
                  );
                },
              ),
              ValueListenableBuilder(
                valueListenable: isAgreeSms,
                builder: (context, value, child) {
                  return AgreeTermsWidget(
                    availableWidth: widget.availableWidth,
                    isAgree: value,
                    onPressed: onCheckSms,
                    label: TextSpan(
                      text: TranslationKeys.authSmsConsent.tr(context: context),
                      style: AppTextStyle.regular14(context, aW: aW, color: StaticColors.c9AA0A6),
                    ),
                  );
                },
              ),
              CustomButton(
                height: widget.buttonHeight ?? context.wOf(48, aW),
                textStyle: AppTextStyle.regular16(context, color: StaticColors.primary),
                label: TranslationKeys.continueText.tr(context: context),
                isLoading: signUpBusy,
                onPressed: busy ? null : () => onSubmitSignUpPhone(context),
              ),
              Row(
                spacing: 16,
                children: [
                  Expanded(child: Divider(color: StaticColors.cD9D9D9)),
                  Text(
                    TranslationKeys.or.tr(context: context),
                    style: AppTextStyle.regular14(context, color: StaticColors.cBDC1C6),
                  ),
                  Expanded(child: Divider(color: StaticColors.cD9D9D9)),
                ],
              ),
              // CustomButton(
              //   borderRadius: 30,
              //   suffixIcon: Assets.icons.appleIcon.svg(),
              //   height: widget.buttonHeight ?? context.wOf(48, aW),
              //   backgroundColor: StaticColors.backgroundColor,
              //   foregroundColor: StaticColors.primary,
              //   textStyle: AppTextStyle.regular16(context, aW: aW),
              //   label: TranslationKeys.signInWithApple.tr(context: context),
              //   isLoading: appleBusy,
              //   onPressed: busy ? null : () => onAppleSignUp(context),
              // ),
              // CustomButton(
              //   borderRadius: 30,
              //   suffixIcon: Assets.icons.googleIcon.svg(),
              //   height: widget.buttonHeight ?? context.wOf(48, aW),
              //   backgroundColor: StaticColors.backgroundColor,
              //   foregroundColor: StaticColors.primary,
              //   textStyle: AppTextStyle.regular16(context, aW: aW),
              //   label: TranslationKeys.signInWithGoogle.tr(context: context),
              //   isLoading: googleBusy,
              //   onPressed: busy ? null : () => onGoogleSignUp(context),
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    TranslationKeys.alreadyHaveAccount.tr(context: context),
                    style: AppTextStyle.regular12(context, color: StaticColors.c9AA0A6, aW: aW),
                  ),
                  TextButton(
                    onPressed: () => context.router.pop(),
                    child: Text(
                      TranslationKeys.signIn.tr(context: context),
                      style: AppTextStyle.regular12(context, color: StaticColors.primary, aW: aW),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
