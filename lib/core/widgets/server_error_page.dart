import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:flutter/material.dart';

@RoutePage()
class ServerErrorPage extends ResponsiveSection {
  const ServerErrorPage({super.key});

  void _retry(BuildContext context) {
    context.router.replace(const SplashRoute());
  }

  @override
  Widget buildMobile(BuildContext context) {
    final primaryColor = StaticColors.primary;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _retry(context);
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _retry(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: context.screenWidth * 0.5,
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 120,
                          color: primaryColor.withAlpha(126),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.size35),
                Text(
                  TranslationKeys.serverErrorTitle.tr(context: context),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.medium24(context), //
                ),
                SizedBox(height: context.size16),
                Text(
                  TranslationKeys.serverErrorDescription.tr(context: context),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.regular16(
                    context,
                    color: Colors.grey.shade600,
                  ), //
                ),
                SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () => _retry(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      TranslationKeys.retry.tr(context: context),
                      style: AppTextStyle.regular18(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget buildTablet(BuildContext context) {
    final primaryColor = StaticColors.primary;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _retry(context);
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => _retry(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: context.screenWidth * 0.3,
                  decoration: BoxDecoration(
                    color: primaryColor.withAlpha(30),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 120,
                          color: primaryColor.withAlpha(126),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: context.size35),
                Text(
                  TranslationKeys.serverErrorTitle.tr(context: context),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.medium28(context), //
                ),
                SizedBox(height: context.size16),
                Text(
                  TranslationKeys.serverErrorDescription.tr(context: context),
                  textAlign: TextAlign.center,
                  style: AppTextStyle.regular20(
                    context,
                    color: Colors.grey.shade600,
                  ), //
                ),
                SizedBox(height: 50),
                SizedBox(
                  width: double.infinity,
                  height: 70,
                  child: ElevatedButton(
                    onPressed: () => _retry(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      TranslationKeys.retry.tr(context: context),
                      style: AppTextStyle.regular18(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
