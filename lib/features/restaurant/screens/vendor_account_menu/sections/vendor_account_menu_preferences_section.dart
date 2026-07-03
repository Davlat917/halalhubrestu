import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/widgets/vendor_account_menu_tile.dart';

/// Divider + Settings, Notification, Language.
class VendorAccountMenuPreferencesSection extends StatelessWidget {
  const VendorAccountMenuPreferencesSection({
    super.key,
    required this.onSettingsTap,
    required this.onNotificationTap,
    required this.onLanguageTap,
  });

  final void Function(BuildContext context) onSettingsTap;
  final void Function(BuildContext context) onNotificationTap;
  final void Function(BuildContext context) onLanguageTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Divider(height: 1, color: StaticColors.cE2E2E2),
        ),
        VendorAccountMenuTile(
          iconAsset: Assets.icons.profileIcon,
          label: TranslationKeys.settings.tr(context: context),
          onTap: () => onSettingsTap(context),
        ),
        VendorAccountMenuTile(
          iconAsset: Assets.icons.notificationIcon,
          label: TranslationKeys.notification.tr(context: context),
          onTap: () => onNotificationTap(context),
        ),
        VendorAccountMenuTile(
          iconAsset: Assets.icons.languageIcon,
          label: TranslationKeys.language.tr(context: context),
          onTap: () => onLanguageTap(context),
        ),
      ],
    );
  }
}
