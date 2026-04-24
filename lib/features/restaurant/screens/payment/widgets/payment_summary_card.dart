import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class PaymentSummaryCard extends StatelessWidget {
  const PaymentSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.iconAsset,
    required this.iconBg,
  });

  final String title;
  final String amount;
  final String iconAsset;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight <= 110;
        final iconBoxSize = isCompact ? 30.0 : 34.0;
        return ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 150),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: isCompact ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: StaticColors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: StaticColors.cE2E2E2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: iconBoxSize,
                  height: iconBoxSize,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      iconAsset,
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: isCompact ? 6 : 10),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.regular12(
                    context,
                    size: isCompact ? 11 : 12,
                    color: StaticColors.c9AA0A6,
                  ),
                ),
                SizedBox(height: isCompact ? 2 : 4),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      amount,
                      maxLines: 1,
                      style: AppTextStyle.semibold18(
                        context,
                        size: isCompact ? 16 : 18,
                        color: StaticColors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
