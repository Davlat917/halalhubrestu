import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/models/payment_history_row.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/sections/payment_history_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/widgets/payment_payout_notice_card.dart';

class PaymentManagementSection extends StatelessWidget {
  const PaymentManagementSection({
    super.key,
    required this.isManualPayout,
    required this.rows,
    required this.status,
    this.errorMessage,
    this.onRetry,
    this.isLoadingMore = false,
    required this.onWithdrawPressed,
    this.withdrawButtonWidth = 200,
  });

  final bool isManualPayout;
  final List<PaymentHistoryRowData> rows;
  final PaymentDashboardStatus status;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isLoadingMore;
  final VoidCallback onWithdrawPressed;
  final double withdrawButtonWidth;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                TranslationKeys.paymentManagement.tr(context: context),
                style: AppTextStyle.semibold18(context),
              ),
            ),
            if (isManualPayout) ...[
              const SizedBox(width: 12),
              SizedBox(
                width: withdrawButtonWidth,
                height: 44,
                child: CustomButton(
                  label: TranslationKeys.paymentWithdrawFromBank.tr(
                    context: context,
                  ),
                  onPressed: onWithdrawPressed,
                  backgroundColor: StaticColors.primary,
                  foregroundColor: StaticColors.white,
                  borderRadius: 10,
                  height: 44,
                  textStyle: AppTextStyle.medium16(
                    context,
                    size: 14,
                    color: StaticColors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        PaymentPayoutNoticeCard(
          title: isManualPayout
              ? TranslationKeys.paymentManualWithdrawal.tr(context: context)
              : TranslationKeys.paymentWeeklyPayoutNoticeTitle.tr(
                  context: context,
                ),
          description: isManualPayout
              ? TranslationKeys.paymentManualWithdrawDescription.tr(
                  context: context,
                )
              : TranslationKeys.paymentWeeklyPayoutNoticeDescription.tr(
                  context: context,
                ),
          icon: isManualPayout
              ? Icons.payments_outlined
              : Icons.account_balance_rounded,
        ),
        const SizedBox(height: 12),
        PaymentHistorySection(
          rows: rows,
          status: status,
          errorMessage: errorMessage,
          onRetry: onRetry,
          isLoadingMore: isLoadingMore,
        ),
      ],
    );
  }
}

bool isManualPayoutSchedule(String payoutSchedule) {
  return payoutSchedule.trim().toLowerCase() == 'manual';
}
