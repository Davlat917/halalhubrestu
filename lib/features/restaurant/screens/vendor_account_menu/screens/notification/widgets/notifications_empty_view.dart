import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class NotificationsEmptyView extends StatelessWidget {
  const NotificationsEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 88,
              color: StaticColors.cD1D1D1,
            ),
            const SizedBox(height: 16),
            Text(
              TranslationKeys.notificationsEmpty.tr(context: context),
              style: AppTextStyle.medium14(
                context,
                size: 16,
                color: StaticColors.c9AA0A6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
