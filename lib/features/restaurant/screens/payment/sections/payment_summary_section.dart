import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_wallet_dashboard/vendor_wallet_dashboard_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/widgets/payment_summary_card.dart';

class PaymentSummarySection extends StatelessWidget {
  const PaymentSummarySection({
    super.key,
    required this.dashboard,
    required this.status,
    required this.onRetry,
  });

  final VendorWalletDashboardModel dashboard;
  final PaymentDashboardStatus status;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (status == PaymentDashboardStatus.failure) {
      return Center(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(
              TranslationKeys.paymentFailedLoadDashboard.tr(context: context),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: onRetry,
              child: Text(TranslationKeys.retry.tr(context: context)),
            ),
          ],
        ),
      );
    }
    if (status == PaymentDashboardStatus.initial ||
        status == PaymentDashboardStatus.loading) {
      return const SizedBox(
        height: 92,
        child: Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final cards = [
      (
        TranslationKeys.paymentCurrentBalanceCard.tr(context: context),
        _formatMoney(dashboard.currentBalance),
        'assets/icons/payment_summary_icon1.svg',
        const Color(0xFFE8F5FB),
      ),
      (
        TranslationKeys.paymentScheduledPayouts.tr(context: context),
        _formatMoney(dashboard.availableForWithdrawal),
        'assets/icons/payment_summery_icon2.svg',
        const Color(0xFFF8E9FB),
      ),
      (
        TranslationKeys.paymentDebts.tr(context: context),
        _formatMoney(dashboard.totalPlatformDebt),
        'assets/icons/payment_summery_icon3.svg',
        const Color(0xFFFFEEEE),
      ),
      (
        TranslationKeys.paymentPendingPayouts.tr(context: context),
        _formatMoney(dashboard.pendingPayoutsSum),
        'assets/icons/payment_summery_icon4.svg',
        const Color(0xFFFFF6DF),
      ),
      (
        TranslationKeys.paymentTotalEarnings.tr(context: context),
        _formatMoney(dashboard.totalEarned),
        'assets/icons/payment_summery_icon5.svg',
        const Color(0xFFEAF8EF),
      ),
    ];

    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final c = cards[index];
          return SizedBox(
            width: 190,
            child: PaymentSummaryCard(
              title: c.$1,
              amount: c.$2,
              iconAsset: c.$3,
              iconBg: c.$4,
            ),
          );
        },
      ),
    );
  }

  String _formatMoney(double value) {
    final normalized = value.toStringAsFixed(2);
    if (normalized.endsWith('.00')) {
      return '\$${normalized.substring(0, normalized.length - 3)}';
    }
    return '\$$normalized';
  }
}
