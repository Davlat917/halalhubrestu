import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class VendorProfileTabBar extends StatelessWidget {
  const VendorProfileTabBar({super.key, required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(String label, int index) {
      final active = selected == index;
      return Padding(
        padding: const EdgeInsets.only(right: 16),
        child: InkWell(
          onTap: () => onChanged(index),
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.regular18(context, size: 16, color: active ? StaticColors.primary : StaticColors.c9AA0A6),
                  ),
                ),
                Container(height: 3, width: double.infinity, color: active ? StaticColors.primary : StaticColors.transparent),
              ],
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Row(
          spacing: 16,
          children: [
            tab(TranslationKeys.vendorProfileMenuView.tr(context: context), 0),
            tab(TranslationKeys.vendorProfileAboutRestaurant.tr(context: context), 1),
            tab(TranslationKeys.agreementTitle.tr(context: context), 2),
          ],
        ),
      ),
    );
  }
}
