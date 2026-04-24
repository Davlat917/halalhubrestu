import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/widgets/payment_dashed_line.dart';

class PaymentCommissionSection extends StatelessWidget {
  const PaymentCommissionSection({
    super.key,
    required this.commissionDescription,
    required this.halalHubFee,
  });

  final String commissionDescription;
  final String halalHubFee;

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
          Text(
            TranslationKeys.paymentCommissionRate.tr(context: context),
            style: AppTextStyle.semibold20(context, size: 16),
          ),
          const SizedBox(height: 4),
          Text(
            commissionDescription,
            style: AppTextStyle.regular14(context, color: StaticColors.c9AA0A6),
          ),
          const SizedBox(height: 10),
          const PaymentDashedLine(),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  TranslationKeys.paymentHalalHubFee.tr(context: context),
                  style: AppTextStyle.medium16(context),
                ),
              ),
              Text(
                halalHubFee,
                style: AppTextStyle.semibold20(context, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
