import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/auth/sreens/sign_in/widgets/sign_in_email_widget.dart';

class SignInCardSection extends StatelessWidget {
  final double? availableWidth;
  final double? availableHeight;
  final double? buttonHeight;

  const SignInCardSection({
    super.key,
    this.availableWidth,
    this.availableHeight,
    this.buttonHeight,
  });

  @override
  Widget build(BuildContext context) {
    final aW = availableWidth ?? context.screenWidth;
    final aH = availableHeight ?? context.screenHeight;
    return SizedBox(
      height: aH,
      width: aW,
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: aH),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.all(context.wOf(16, aW)),
                padding: EdgeInsets.all(context.wOf(20, aW)),
                decoration: BoxDecoration(
                  color: StaticColors.white,
                  borderRadius: BorderRadius.circular(context.wOf(20, aW)),
                  border: Border.all(color: StaticColors.cE2E2E2),
                ),
                child: Column(
                  spacing: context.wOf(20, aW),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      TranslationKeys.authSignInTitle.tr(context: context),
                      style: AppTextStyle.medium24(
                        context,
                        color: StaticColors.primary,
                        aW: aW,
                      ),
                    ),
                    Text(
                      TranslationKeys.authSignInSubtitle.tr(context: context),
                      textAlign: TextAlign.center,
                      style: AppTextStyle.regular16(
                        context,
                        color: StaticColors.cBDC1C6,
                        aW: aW,
                      ),
                    ),
                    SignInEmailWidget(
                      availableWidth: aW,
                      buttonHeight: buttonHeight,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
