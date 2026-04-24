import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/models/payment_history_row.dart';

class PaymentStatusBadge extends StatelessWidget {
  const PaymentStatusBadge({
    super.key,
    required this.status,
    this.statusLabel,
  });

  final PaymentStatus status;
  final String? statusLabel;

  @override
  Widget build(BuildContext context) {
    final (defaultLabel, fg, bg) = switch (status) {
      PaymentStatus.verified => (
          'Verified',
          const Color(0xFF32A86B),
          const Color(0xFFEAF8EF),
        ),
      PaymentStatus.pending => (
          'Pending',
          const Color(0xFFD8A41B),
          const Color(0xFFFFF6DF),
        ),
      PaymentStatus.failed => (
          'Failed',
          const Color(0xFFE45A6A),
          const Color(0xFFFFEEEE),
        ),
    };
    final label = statusLabel ?? defaultLabel;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTextStyle.medium10(context, size: 13, color: fg),
      ),
    );
  }
}
