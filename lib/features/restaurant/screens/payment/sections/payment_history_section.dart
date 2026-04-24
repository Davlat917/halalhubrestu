import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/models/payment_history_row.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/widgets/payment_status_badge.dart';

class PaymentHistorySection extends StatelessWidget {
  const PaymentHistorySection({
    super.key,
    required this.rows,
    required this.status,
    this.errorMessage,
    this.onRetry,
    this.isLoadingMore = false,
  });

  final List<PaymentHistoryRowData> rows;
  final PaymentDashboardStatus status;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final bool isLoadingMore;

  static const _cellPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 12,
  );
  static const _cellPaddingRow = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 11,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (status == PaymentDashboardStatus.failure && errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              child: Column(
                children: [
                  Text(
                    errorMessage!,
                    style: AppTextStyle.regular14(
                      context,
                      color: StaticColors.c666666,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (onRetry != null)
                    FilledButton(
                      onPressed: onRetry,
                      child: Text(TranslationKeys.retry.tr(context: context)),
                    ),
                ],
              ),
            )
          else if (status == PaymentDashboardStatus.initial ||
              status == PaymentDashboardStatus.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              child: Text(
                TranslationKeys.paymentNoPayoutRequests.tr(context: context),
                style: AppTextStyle.regular14(
                  context,
                  color: StaticColors.c666666,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: Table(
                          columnWidths: const {
                            0: IntrinsicColumnWidth(),
                            1: IntrinsicColumnWidth(),
                            2: IntrinsicColumnWidth(),
                            3: IntrinsicColumnWidth(),
                          },
                          defaultVerticalAlignment:
                              TableCellVerticalAlignment.middle,
                          border: TableBorder(
                            top: BorderSide.none,
                            horizontalInside: const BorderSide(
                              color: StaticColors.cF0F0F0,
                            ),
                            bottom: BorderSide.none,
                            left: BorderSide.none,
                            right: BorderSide.none,
                          ),
                          children: [
                            TableRow(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: StaticColors.cE2E2E2,
                                  ),
                                ),
                              ),
                              children: [
                                Padding(
                                  padding: _cellPadding,
                                  child: Text(
                                    TranslationKeys.paymentId.tr(
                                      context: context,
                                    ),
                                    style: AppTextStyle.medium14(
                                      context,
                                      color: StaticColors.black,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: _cellPadding,
                                  child: Text(
                                    '${TranslationKeys.paymentDate.tr(context: context)} ^',
                                    style: AppTextStyle.medium14(
                                      context,
                                      color: StaticColors.black,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: _cellPadding,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      '${TranslationKeys.paymentStatus.tr(context: context)} ^',
                                      style: AppTextStyle.medium14(
                                        context,
                                        color: StaticColors.black,
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: _cellPadding,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      TranslationKeys.paymentAmount.tr(
                                        context: context,
                                      ),
                                      style: AppTextStyle.medium14(
                                        context,
                                        color: StaticColors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            for (final row in rows)
                              TableRow(
                                children: [
                                  Padding(
                                    padding: _cellPaddingRow,
                                    child: _ScrollableCellText(
                                      text: row.id,
                                      style: AppTextStyle.regular12(
                                        context,
                                        color: StaticColors.c666666,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: _cellPaddingRow,
                                    child: _ScrollableCellText(
                                      text: row.date,
                                      style: AppTextStyle.regular12(
                                        context,
                                        color: StaticColors.c666666,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: _cellPaddingRow,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: PaymentStatusBadge(
                                        status: row.status,
                                        statusLabel: row.statusLabel,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: _cellPaddingRow,
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: _ScrollableCellText(
                                        text: row.amount,
                                        style: AppTextStyle.regular12(
                                          context,
                                          color: StaticColors.c666666,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator.adaptive(
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Uzun qator bo‘lsa ustun kengayadi; butun jadval [SingleChildScrollView] orqali gorizontal silinadi.
class _ScrollableCellText extends StatelessWidget {
  const _ScrollableCellText({
    required this.text,
    required this.style,
    this.textAlign,
  });

  final String text;
  final TextStyle style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.visible,
    );
  }
}
