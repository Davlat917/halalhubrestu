import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';

class ChangePasswordConfirmFormSection extends StatelessWidget {
  const ChangePasswordConfirmFormSection({
    super.key,
    required this.formKey,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
    required this.validatePassword,
    required this.validateConfirmPassword,
    required this.onSubmit,
    required this.maxContentWidth,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool isLoading;
  final String? Function(String?) validatePassword;
  final String? Function(String?) validateConfirmPassword;
  final VoidCallback onSubmit;
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    Widget child = ListView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: StaticColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: StaticColors.cE2E2E2),
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  TranslationKeys.resetPassword.tr(context: context),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.semibold18(context),
                ),
                const SizedBox(height: 8),
                Text(
                  TranslationKeys.chooseNewPassword.tr(context: context),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.regular14(
                    context,
                    color: StaticColors.c666666,
                  ),
                ),
                const SizedBox(height: 18),
                CommonTextField(
                  controller: passwordController,
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  hint: TranslationKeys.authPassword.tr(context: context),
                  validator: validatePassword,
                ),
                const SizedBox(height: 12),
                CommonTextField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  hint: TranslationKeys.authConfirmPassword.tr(
                    context: context,
                  ),
                  validator: validateConfirmPassword,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  label: TranslationKeys.resetPassword.tr(context: context),
                  isLoading: isLoading,
                  onPressed: isLoading ? null : onSubmit,
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (maxContentWidth != null) {
      child = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth!),
          child: child,
        ),
      );
    }
    return child;
  }
}
