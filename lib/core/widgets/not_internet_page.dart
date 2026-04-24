import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';
import 'package:flutter/material.dart';

// ColorFilter const qilib oldindan tayyorlanadi — har build'da yangi obyekt yaratilmaydi
const _kSvgColorFilter = ColorFilter.mode(
  StaticColors.primary,
  BlendMode.srcIn,
);

const _kDescColor = Color(0xFFBDC1C6);

@RoutePage()
class NotInternetPage extends ResponsiveSection {
  const NotInternetPage({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget buildMobile(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(38.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // RepaintBoundary — SVG atrofdagi widgetlardan ajratiladi
            RepaintBoundary(
              child: Assets.icons.notConnected.svg(
                width: context.screenWidth * 0.5,
                colorFilter: _kSvgColorFilter, // const — yangi obyekt yo'q
              ),
            ),
            SizedBox(height: context.size16),
            Text(
              TranslationKeys.notInternetTitle.tr(context: context),
              style: AppTextStyle.bold20(context, color: _kDescColor),
            ),
            Text(
              TranslationKeys.notInternetDescription.tr(context: context),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kDescColor,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
            SizedBox(height: context.size35),
            CustomButton(
              label: TranslationKeys.retry.tr(context: context),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildTablet(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 38, horizontal: 150),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // buildTablet'da ham RepaintBoundary qo'shildi
            RepaintBoundary(
              child: Assets.icons.notConnected.svg(
                width: context.screenWidth * 0.5,
                colorFilter: _kSvgColorFilter,
              ),
            ),
            SizedBox(height: context.size16),
            Text(
              TranslationKeys.notInternetTitle.tr(context: context),
              style: AppTextStyle.bold24(context, color: _kDescColor),
            ),
            Text(
              TranslationKeys.notInternetDescription.tr(context: context),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kDescColor,
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            SizedBox(height: context.size35),
            CustomButton(
              height: 60,
              textStyle: AppTextStyle.medium22(context),
              label: TranslationKeys.retry.tr(context: context),
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
