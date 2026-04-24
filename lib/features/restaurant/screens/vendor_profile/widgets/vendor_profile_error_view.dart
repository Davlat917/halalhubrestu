import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';

class VendorProfileErrorView extends StatelessWidget {
  const VendorProfileErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyle.regular14(
                context,
                color: StaticColors.c666666,
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: TranslationKeys.retry.tr(context: context),
              onPressed: onRetry,
              backgroundColor: StaticColors.primary,
              foregroundColor: StaticColors.white,
            ),
          ],
        ),
      ),
    );
  }
}
