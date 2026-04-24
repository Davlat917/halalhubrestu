import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/mixins/validation_mixin.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/circle_btn_widget.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';
import 'package:halalhub_restaurant/features/auth/sreens/forgot_password/mixins/forgot_password_mixin.dart';

class ForgotPasswordCardWidget extends StatefulWidget {
  final double? availableHeight;
  final double? availableWidth;
  final double? buttonHeight;

  const ForgotPasswordCardWidget({
    super.key,
    this.availableHeight,
    this.availableWidth,
    this.buttonHeight,
  });

  @override
  State<ForgotPasswordCardWidget> createState() =>
      _ForgotPasswordCardWidgetState();
}

class _ForgotPasswordCardWidgetState extends State<ForgotPasswordCardWidget>
    with ValidationMixin, ForgotPasswordMixin {
  @override
  Widget build(BuildContext context) {
    final aH = widget.availableHeight ?? MediaQuery.sizeOf(context).height;
    final aW = widget.availableWidth ?? MediaQuery.sizeOf(context).width;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (p, c) {
        if (p is! AuthLoading ||
            p.action != AuthPendingAction.passwordResetRequest) {
          return false;
        }
        return c is AuthFailure || c is AuthSuccess;
      },
      listener: (context, state) => handleForgotPasswordEffects(context, state),
      builder: (context, state) {
        final busy = state is AuthLoading;
        final pending = state is AuthLoading ? state.action : null;
        final requestBusy = pending == AuthPendingAction.passwordResetRequest;
        final viewInsets = MediaQuery.of(context).viewInsets.bottom;
        return Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 40, 20, 24 + viewInsets),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: aH - 80),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        constraints: BoxConstraints(maxWidth: aW),
                        decoration: BoxDecoration(
                          color: StaticColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: StaticColors.cE2E2E2),
                        ),
                        child: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                TranslationKeys.resetPassword.tr(
                                  context: context,
                                ),
                                textAlign: TextAlign.center,
                                style: AppTextStyle.semibold24(
                                  context,
                                  aW: aW,
                                  color: StaticColors.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                TranslationKeys.resetPasswordDescription.tr(
                                  context: context,
                                ),
                                textAlign: TextAlign.center,
                                style: AppTextStyle.regular16(
                                  context,
                                  aW: aW,
                                  color: StaticColors.c9AA0A6,
                                ),
                              ),
                              const SizedBox(height: 24),
                              CommonTextField(
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                availableWidth: aW,
                                hint: TranslationKeys.authEmail.tr(
                                  context: context,
                                ),
                                validator: validateEmail, //
                              ),
                              const SizedBox(height: 16),
                              CustomButton(
                                textStyle: AppTextStyle.regular16(
                                  context,
                                  aW: aW,
                                  color: StaticColors.white,
                                ),
                                height: widget.buttonHeight ?? 48,
                                label: TranslationKeys.continueText.tr(
                                  context: context,
                                ),
                                isLoading: requestBusy,
                                onPressed: busy
                                    ? null
                                    : () => onSubmitForgotPassword(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              child: CircleBtnWidget(
                onPress: () => Navigator.of(context).maybePop(),
              ),
            ),
          ],
        );
      },
    );
  }
}
