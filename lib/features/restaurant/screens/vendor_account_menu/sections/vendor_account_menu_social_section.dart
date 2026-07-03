import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/widgets/vendor_account_menu_tile.dart';

/// Divider + Instagram, WhatsApp, Phone.
class VendorAccountMenuSocialSection extends StatelessWidget {
  const VendorAccountMenuSocialSection({
    super.key,
    required this.onInstagramTap,
    required this.onWhatsappTap,
    required this.onPhoneTap,
  });

  final void Function(BuildContext context) onInstagramTap;
  final void Function(BuildContext context) onWhatsappTap;
  final void Function(BuildContext context) onPhoneTap;

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
          iconAsset: Assets.icons.instagram,
          label: TranslationKeys.accountInstagram.tr(context: context),
          preserveIconColors: true,
          iconSize: 22,
          iconScale: 1.38,
          onTap: () => onInstagramTap(context),
        ),
        VendorAccountMenuTile(
          iconAsset: Assets.icons.whatsapp,
          label: TranslationKeys.accountWhatsapp.tr(context: context),
          preserveIconColors: true,
          iconSize: 22,
          onTap: () => onWhatsappTap(context),
        ),
        VendorAccountMenuTile(
          iconAsset: Assets.icons.call,
          label: TranslationKeys.accountPhone.tr(context: context),
          preserveIconColors: true,
          iconSize: 22,
          onTap: () => onPhoneTap(context),
        ),
      ],
    );
  }
}
