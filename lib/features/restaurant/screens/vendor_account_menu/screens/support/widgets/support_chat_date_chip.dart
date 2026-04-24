import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class SupportChatDateChip extends StatelessWidget {
  const SupportChatDateChip({super.key, required this.date});

  final DateTime date;

  String _formatDate() {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year;
    return '$d.$m.$y';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: StaticColors.cF4F4F4,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          _formatDate(),
          style: AppTextStyle.regular12(context, color: StaticColors.c666666),
        ),
      ),
    );
  }
}
