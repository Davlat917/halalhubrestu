import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

class VendorAccountMenuTile extends StatelessWidget {
  const VendorAccountMenuTile({
    super.key,
    required this.iconAsset,
    required this.label,
    required this.onTap,
    this.iconColor = StaticColors.black,
    this.labelColor = StaticColors.black,
    this.showTrailing = true,
  });

  final SvgGenImage iconAsset;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;
  final bool showTrailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 24,
        height: 24,
        child: iconAsset.svg(
          width: 24,
          height: 24,
          fit: BoxFit.contain,
          colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        ),
      ),
      title: Text(label, style: AppTextStyle.medium16(context, size: 15, color: labelColor)),
      trailing: showTrailing ? Icon(Icons.chevron_right_rounded, color: StaticColors.c666666.withValues(alpha: 0.6)) : null,
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
