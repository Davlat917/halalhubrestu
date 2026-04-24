import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/vendor_account_menu_handlers.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/widgets/vendor_account_menu_tile.dart';

/// Log out va Delete (qizil).
class VendorAccountMenuDestructiveSection extends StatelessWidget {
  const VendorAccountMenuDestructiveSection({super.key});

  static const SvgGenImage _logoutIcon = SvgGenImage(
    'assets/icons/logout_icon.svg',
  );

  @override
  Widget build(BuildContext context) {
    final c = VendorAccountMenuHandlers.destructive;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        VendorAccountMenuTile(
          iconAsset: _logoutIcon,
          label: TranslationKeys.logout.tr(context: context),
          iconColor: c,
          labelColor: c,
          showTrailing: false,
          onTap: () => VendorAccountMenuHandlers.showLogOutPlaceholder(context),
        ),
        VendorAccountMenuTile(
          iconAsset: Assets.icons.deleteIcon,
          label: TranslationKeys.delete.tr(context: context),
          iconColor: c,
          labelColor: c,
          showTrailing: false,
          onTap: () => context.router.push(const DeleteAccountReasonRoute()),
        ),
      ],
    );
  }
}
