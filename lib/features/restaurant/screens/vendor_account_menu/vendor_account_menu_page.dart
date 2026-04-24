import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/sections/vendor_account_menu_destructive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/sections/vendor_account_menu_general_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/sections/vendor_account_menu_preferences_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/vendor_account_menu_handlers.dart';

/// Vendor logotip / avatar orqali ochiladigan hisob menyusi.
@RoutePage()
class VendorAccountMenuPage extends StatelessWidget {
  const VendorAccountMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaticColors.white,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: StaticColors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: StaticColors.black,
            size: 20,
          ),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          TranslationKeys.accountTitle.tr(context: context),
          style: AppTextStyle.semibold18(context),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: [
          VendorAccountMenuGeneralSection(
            onSupportTap: (context) =>
                context.router.push(const SupportChatRoute()),
            onUsageTap: VendorAccountMenuHandlers.showComingSoon, //
          ),
          VendorAccountMenuPreferencesSection(
            onNotificationTap: (context) =>
                context.router.push(const NotificationRoute()),
            onLanguageTap: VendorAccountMenuHandlers.showLanguagePicker,
          ),
          const VendorAccountMenuDestructiveSection(),
        ],
      ),
    );
  }
}
