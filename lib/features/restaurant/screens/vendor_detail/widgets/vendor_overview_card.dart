import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class VendorOverviewCardData {
  const VendorOverviewCardData({
    required this.title,
    required this.amount,
    required this.changeText,
    required this.changeColor,
    required this.status, //
  });

  final String title;
  final String amount;
  final String changeText;
  final Color changeColor;
  final String status;
}

class VendorOverviewCard extends StatelessWidget {
  const VendorOverviewCard({super.key, required this.item, required this.isLoading});

  final VendorOverviewCardData item;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFEAF4FF), borderRadius: BorderRadius.circular(10)),
            child: SvgPicture.asset('assets/icons/calendar.svg', fit: BoxFit.contain),
          ),
          const Spacer(),
          Text(item.title, style: AppTextStyle.regular12(context, color: StaticColors.c9AA0A6)),
          const SizedBox(height: 4),
          Text(isLoading ? 'Loading...' : item.amount, style: AppTextStyle.semibold18(context, color: StaticColors.black)),
          const SizedBox(height: 3),
          Row(
            children: [
              if (!isLoading && item.status != 'same')
                SvgPicture.asset(
                  item.status == 'down' ? 'assets/icons/change_status_down.svg' : 'assets/icons/change_status_up.svg',
                  width: 12,
                  height: 12, //
                ),
              if (!isLoading && item.status != 'same') const SizedBox(width: 2),
              Text(isLoading ? '' : item.changeText, style: AppTextStyle.medium10(context, color: item.changeColor)),
            ],
          ),
        ],
      ),
    );
  }
}
