import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class VendorCategoryChip extends StatelessWidget {
  const VendorCategoryChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? StaticColors.primary : StaticColors.white,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? StaticColors.primary : StaticColors.cE2E2E2,
            ),
          ),
          child: Text(
            label,
            style: AppTextStyle.medium12(
              context,
              color: selected ? StaticColors.white : StaticColors.black,
            ),
          ),
        ),
      ),
    );
  }
}
