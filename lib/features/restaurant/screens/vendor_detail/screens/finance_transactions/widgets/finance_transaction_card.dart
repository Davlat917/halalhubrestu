import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_transaction_item_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/widgets/finance_transaction_info_chip.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/widgets/finance_transaction_line_item_row.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/widgets/finance_transaction_status_badge.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/widgets/finance_transaction_utils.dart';

class FinanceTransactionCard extends StatelessWidget {
  const FinanceTransactionCard({super.key, required this.transaction});

  final VendorFinanceTransactionItemModel transaction;

  @override
  Widget build(BuildContext context) {
    final statusStyle = financeTransactionStatusColors(transaction.status);

    return Container(
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        financeTransactionOrderLabel(transaction.orderNumber),
                        style: AppTextStyle.semibold16(
                          context,
                          color: StaticColors.black,
                        ),
                      ),
                    ),
                    FinanceTransactionStatusBadge(
                      label: shortFinanceTransactionStatusLabel(
                        transaction.statusDisplay,
                      ),
                      background: statusStyle.background,
                      foreground: statusStyle.foreground,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        transaction.customerName,
                        style: AppTextStyle.semibold14(
                          context,
                          color: StaticColors.black,
                        ),
                      ),
                    ),
                    Text(
                      formatFinanceTransactionMoney(transaction.totalPrice),
                      style: AppTextStyle.semibold16(
                        context,
                        color: StaticColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          FinanceTransactionInfoChip(
                            label: capitalizeFinanceTransactionLabel(
                              transaction.orderType,
                            ),
                            background: const Color(0xFFF3E8FF),
                            foreground: const Color(0xFF7C3AED),
                          ),
                          FinanceTransactionInfoChip(
                            label: capitalizeFinanceTransactionLabel(
                              transaction.paymentType,
                            ),
                            background: const Color(0xFFEAF4FF),
                            foreground: const Color(0xFF2563EB),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(
                        financeTransactionDisplayDate(
                          transaction.formattedDate,
                        ),
                        maxLines: 1,
                        softWrap: false,
                        textAlign: TextAlign.right,
                        style: AppTextStyle.regular12(
                          context,
                          color: StaticColors.c9AA0A6,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: StaticColors.cE2E2E2),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              children: [
                for (var i = 0; i < transaction.items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  FinanceTransactionLineItemRow(item: transaction.items[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
