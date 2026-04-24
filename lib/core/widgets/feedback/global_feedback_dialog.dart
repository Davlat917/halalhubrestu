import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';

void showGlobalFailureFeedback(
  BuildContext context, {
  required String message,
  String? title,
}) {
  _showGlobalFeedbackDialog(
    context,
    title: title ?? TranslationKeys.errorOccurredTitle.tr(context: context),
    message: message,
    icon: Icons.error_outline_rounded,
    iconBackground: StaticColors.cFFEEEE,
    iconColor: StaticColors.redAccent,
  );
}

void showGlobalSuccessFeedback(
  BuildContext context, {
  required String message,
  String? title,
}) {
  _showGlobalFeedbackDialog(
    context,
    title: title ?? TranslationKeys.commonSuccessTitle.tr(context: context),
    message: message,
    icon: Icons.check_circle_outline_rounded,
    iconBackground: StaticColors.cEAF8EF,
    iconColor: StaticColors.primary,
  );
}

void _showGlobalFeedbackDialog(
  BuildContext context, {
  required String title,
  required String message,
  required IconData icon,
  required Color iconBackground,
  required Color iconColor,
}) {
  if (!context.mounted) return;
  showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    builder: (ctx) => Dialog(
      backgroundColor: StaticColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 30),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: StaticColors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: StaticColors.c9AA0A6,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 150,
              child: CustomButton(
                height: 30,
                label: TranslationKeys.commonOk.tr(context: ctx),
                textStyle: AppTextStyle.medium12(
                  ctx,
                  color: StaticColors.black,
                ),
                borderRadius: 100,
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
