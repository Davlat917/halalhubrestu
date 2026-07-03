import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/core/widgets/pincode_text.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class ChangePasswordOtpSection extends StatelessWidget {
  const ChangePasswordOtpSection({
    super.key,
    required this.email,
    required this.otpController,
    required this.otpValue,
    required this.isLoading,
    required this.onChanged,
    required this.onSubmit,
    required this.maxContentWidth,
  });

  final String email;
  final PinInputController otpController;
  final ValueListenable<String> otpValue;
  final bool isLoading;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    Widget child = LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final fieldWidth = context.wOf(42, availableWidth).clamp(38.0, 48.0);
        final fieldHeight = context.wOf(52, availableWidth).clamp(48.0, 56.0);

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: StaticColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: StaticColors.cE2E2E2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    TranslationKeys.changePasswordOtpTitle.tr(context: context),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.semibold18(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    TranslationKeys.changePasswordOtpDescription.tr(
                      context: context,
                      namedArgs: {'email': email},
                    ),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.regular14(
                      context,
                      color: StaticColors.c666666,
                    ),
                  ),
                  const SizedBox(height: 24),
                  PinCodeText(
                    controller: otpController,
                    obSures: false,
                    length: 6,
                    fieldWidth: fieldWidth,
                    fieldHeight: fieldHeight,
                    availableWidth: availableWidth,
                    onChanged: onChanged,
                    onCompleted: onChanged,
                    hasError: false,
                  ),
                  const SizedBox(height: 20),
                  ValueListenableBuilder<String>(
                    valueListenable: otpValue,
                    builder: (context, value, _) {
                      return CustomButton(
                        label: TranslationKeys.changePasswordVerify.tr(
                          context: context,
                        ),
                        isLoading: isLoading,
                        onPressed: value.length == 6 && !isLoading
                            ? onSubmit
                            : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
