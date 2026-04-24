import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_me/vendor_me_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/widgets/receipt_printer_shell_menu.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/widgets/vendor_profile_avatar.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

/// Faqat asosiy kontent ustidagi panel: bildirishnoma, til, vendor (sidebar alohida).
class VendorTabletMainTopBar extends StatelessWidget {
  const VendorTabletMainTopBar({super.key, required this.vendor});

  final VendorMeModel? vendor;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return Material(
      color: StaticColors.white,
      elevation: 0,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(left: context.wOf(12, w), right: 0, top: context.wOf(8, w), bottom: context.wOf(8, w)),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: StaticColors.cE2E2E2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const SizedBox(width: 4),
            ReceiptPrinterShellMenu(iconSize: context.wOf(10, w), showStatusLabel: true),
            const SizedBox(width: 10),
            Flexible(
              child: InkWell(
                onTap: () => context.router.push(const VendorAccountMenuRoute()),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8, top: 6, bottom: 6),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      VendorProfileAvatar(vendor: vendor, radius: context.wOf(6, w)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          vendor?.name ?? 'Vendor',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.medium14(context, size: 13, color: StaticColors.black),
                        ),
                      ),
                      Assets.icons.arrowDown.svg(height: context.wOf(6, w)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
