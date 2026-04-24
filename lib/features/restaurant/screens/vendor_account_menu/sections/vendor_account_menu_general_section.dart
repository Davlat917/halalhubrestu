import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/widgets/vendor_account_menu_tile.dart';

/// Support, Usage.
class VendorAccountMenuGeneralSection extends StatelessWidget {
  const VendorAccountMenuGeneralSection({
    super.key,
    required this.onSupportTap,
    required this.onUsageTap,
  });

  final void Function(BuildContext context) onSupportTap;
  final void Function(BuildContext context) onUsageTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        VendorAccountMenuTile(
          iconAsset: Assets.icons.supportIcon,
          label: TranslationKeys.support.tr(context: context),
          onTap: () => onSupportTap(context), //
        ),
        // VendorAccountMenuTile(
        //   iconAsset: Assets.icons.usageIcon,
        //   label: 'Usage',
        //   onTap: () => onUsageTap(context),
        // ),
      ],
    );
  }
}
