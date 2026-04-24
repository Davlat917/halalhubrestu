import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

/// Vendor kabinetidagi chap menyu bandlari (dizayn mockupiga mos).
enum VendorNavItem { orders, addProduct, detail, profile, payment, clips }

extension VendorNavItemX on VendorNavItem {
  String label(BuildContext context) => switch (this) {
    VendorNavItem.orders => TranslationKeys.vendorNavOrders.tr(
      context: context,
    ),
    VendorNavItem.addProduct => TranslationKeys.vendorNavAddProduct.tr(
      context: context,
    ),
    VendorNavItem.detail => TranslationKeys.vendorNavDetail.tr(
      context: context,
    ),
    VendorNavItem.profile => TranslationKeys.vendorNavProfile.tr(
      context: context,
    ),
    VendorNavItem.payment => TranslationKeys.vendorNavPayment.tr(
      context: context,
    ),
    VendorNavItem.clips => TranslationKeys.vendorNavClips.tr(context: context),
  };

  SvgGenImage get icon => switch (this) {
    VendorNavItem.orders => Assets.icons.productsIcon,
    VendorNavItem.addProduct => Assets.icons.addProductIcon,
    VendorNavItem.detail => Assets.icons.detailIcon,
    VendorNavItem.profile => Assets.icons.profileIcon,
    VendorNavItem.payment => Assets.icons.paymentIcon,
    VendorNavItem.clips => Assets.icons.clipsIcon,
  };

  static List<VendorNavItem> get ordered => VendorNavItem.values;
}
