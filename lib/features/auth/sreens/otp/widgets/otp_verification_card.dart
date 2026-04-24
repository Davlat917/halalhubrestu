import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/core/widgets/pincode_text.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpVerificationCard extends StatefulWidget {
  final double? availableHeight;
  final double? availableWidth;
  final double? buttonHeight;
  final String emailOrPhone;

  /// Masalan: "Email verification" yoki "Reset password".
  final String headline;

  /// Har qanday auth yuklanishi — tugmalar va resend bloklanadi.
  final bool isBusy;

  /// Faqat OTP tekshiruvi — Continue tugmasidagi spinner.
  final bool continueLoading;

  /// Resend OTP so‘rovi yuklanmoqda.
  final bool resendLoading;

  /// Qayta yuborishdan keyin qolgan soniya (masalan 120 → 2:00 dan geri sanash).
  final int resendCooldownRemaining;
  final void Function(String otp)? onContinue;
  final VoidCallback? onResend;

  const OtpVerificationCard({
    super.key,
    this.availableHeight,
    this.availableWidth,
    this.buttonHeight,
    required this.emailOrPhone,
    this.headline = TranslationKeys.otpEmailVerification,
    this.isBusy = false,
    this.continueLoading = false,
    this.resendLoading = false,
    this.resendCooldownRemaining = 0,
    this.onContinue,
    this.onResend,
  });

  @override
  State<OtpVerificationCard> createState() => _OtpVerificationCardState();
}

class _OtpVerificationCardState extends State<OtpVerificationCard> {
  static const int _otpLength = 6;
  final otpCtr = PinInputController();
  String _otpValue = '';

  String _formatCooldown(int totalSeconds) {
    final m = totalSeconds ~/ 60;
    final s = totalSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool get _isFilled => _otpValue.length == _otpLength;

  void _handleContinue() {
    if (!_isFilled || widget.isBusy) return;
    widget.onContinue?.call(_otpValue);
  }

  void _onOtpChanged(String value) {
    setState(() => _otpValue = value);
  }

  Widget _buildResendRow(BuildContext context, double aW) {
    final loading = widget.resendLoading;
    final cooldown = widget.resendCooldownRemaining;
    final canTap =
        !widget.isBusy && !loading && cooldown == 0 && widget.onResend != null;

    if (loading) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: context.wOf(18, aW),
            height: context.wOf(18, aW),
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: context.wOf(10, aW)),
          Text(
            TranslationKeys.otpSendingCode.tr(context: context),
            style: AppTextStyle.regular16(
              context,
              aW: aW,
              color: StaticColors.cBDC1C6,
            ),
          ),
        ],
      );
    }

    if (cooldown > 0) {
      return Text(
        '${TranslationKeys.otpResendIn.tr(context: context)} ${_formatCooldown(cooldown)}',
        textAlign: TextAlign.center,
        style: AppTextStyle.regular16(
          context,
          aW: aW,
          color: StaticColors.cBDC1C6,
        ),
      );
    }

    return GestureDetector(
      onTap: canTap ? widget.onResend : null,
      child: Text(
        TranslationKeys.otpResendCode.tr(context: context),
        style: AppTextStyle.regular16(
          context,
          aW: aW,
          color: canTap ? StaticColors.primary : StaticColors.cBDC1C6,
          decoration: canTap ? TextDecoration.underline : TextDecoration.none,
          decorationColor: StaticColors.primary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aW = widget.availableWidth ?? context.screenWidth;
    final aH = widget.availableHeight ?? context.screenHeight;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;

    final double safeHeight = aH < 400 ? 400.0 : aH;
    final double cardHPadding = aW < 350 ? 20.0 : 40.0;
    final double cardWidth = aW - 32;

    return SizedBox(
      width: aW,
      child: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + viewInsets),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: aH - 32),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                child: Container(
                  width: cardWidth,
                  padding: EdgeInsets.symmetric(
                    horizontal: cardHPadding / 2,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    color: StaticColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: StaticColors.cE2E2E2),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.headline.tr(context: context),
                        style: AppTextStyle.medium24(
                          context,
                          aW: aW,
                          color: StaticColors.primary,
                        ),
                      ),
                      SizedBox(height: safeHeight * 0.015),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: AppTextStyle.regular16(
                            context,
                            aW: aW,
                            color: StaticColors.cBDC1C6,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  '${TranslationKeys.otpSentTo.tr(context: context)}\n',
                            ),
                            TextSpan(
                              text: widget.emailOrPhone,
                              style: AppTextStyle.medium16(
                                context,
                                aW: aW,
                                color: StaticColors.primary,
                              ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                      SizedBox(height: safeHeight * 0.03),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: PinCodeText(
                          controller: otpCtr,
                          obSures: false,
                          length: 6,
                          fieldWidth: context.wOf(40, aW),
                          fieldHeight: context.wOf(50, aW),
                          availableHeight: aH,
                          availableWidth: aW,
                          onChanged: _onOtpChanged,
                          onCompleted: _onOtpChanged,
                          hasError: false,
                        ),
                      ),
                      SizedBox(height: safeHeight * 0.025),
                      _buildResendRow(context, aW),
                      SizedBox(height: safeHeight * 0.025),
                      CustomButton(
                        height: widget.buttonHeight ?? context.wOf(48, aW),
                        label: TranslationKeys.continueText.tr(
                          context: context,
                        ),
                        textStyle: AppTextStyle.medium16(
                          context,
                          aW: aW,
                          color: StaticColors.white,
                        ),
                        isLoading: widget.continueLoading,
                        onPressed: _isFilled && !widget.isBusy
                            ? _handleContinue
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
