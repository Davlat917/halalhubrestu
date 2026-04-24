import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/widgets/receipt_printer_shell_menu.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_profile_avatar.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

/// Mobil: menyu + [Assets.images.logoImage] + profil.
PreferredSizeWidget vendorMobileAppBar({required BuildContext context, required VoidCallback onOpenDrawer, VendorMeModel? vendor}) {
  final w = context.screenWidth;
  return AppBar(
    elevation: 0,
    scrolledUnderElevation: 0,
    backgroundColor: StaticColors.white,
    surfaceTintColor: StaticColors.transparent,
    leading: IconButton(
      icon: Icon(Icons.menu_rounded, color: StaticColors.c666666, size: context.wOf(26, w)),
      onPressed: onOpenDrawer,
    ),
    title: Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Assets.images.logoImage.image(
        height: context.wOf(30, w),
        fit: BoxFit.contain,
      ),
    ),
    centerTitle: true,
    actions: [
      Padding(
        padding: EdgeInsets.only(right: context.wOf(2, w)),
        child: ReceiptPrinterShellMenu(
          iconSize: context.wOf(30, w),
          showStatusLabel: true,
        ),
      ),
      Padding(
        padding: EdgeInsets.only(right: context.wOf(8, w)),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () => context.router.push(const VendorAccountMenuRoute()),
            child: VendorProfileAvatar(vendor: vendor, radius: context.wOf(20, w)),
          ),
        ),
      ),
    ],
  );
}
