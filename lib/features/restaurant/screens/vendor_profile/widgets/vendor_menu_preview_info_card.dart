import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class VendorMenuPreviewInfoCard extends StatelessWidget {
  const VendorMenuPreviewInfoCard({
    super.key,
    required this.maxWidth,
    required this.text,
  });

  final double maxWidth;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.wOf(20, maxWidth)),
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyle.regular14(context, color: StaticColors.c9AA0A6),
      ),
    );
  }
}
