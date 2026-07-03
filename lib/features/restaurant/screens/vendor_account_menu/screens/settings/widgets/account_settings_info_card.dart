import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class AccountSettingsInfoCard extends StatelessWidget {
  const AccountSettingsInfoCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(children: children),
    );
  }
}

class AccountSettingsInfoRow extends StatelessWidget {
  const AccountSettingsInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String? value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final resolvedValue = value?.trim();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 4,
                child: Text(
                  label,
                  style: AppTextStyle.regular14(
                    context,
                    color: StaticColors.c666666,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 6,
                child: Text(
                  resolvedValue == null || resolvedValue.isEmpty
                      ? '-'
                      : resolvedValue,
                  textAlign: TextAlign.end,
                  style: AppTextStyle.medium14(context),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.only(left: 16),
            child: Divider(height: 1, color: StaticColors.cE2E2E2),
          ),
      ],
    );
  }
}
