import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class SupportChatInputSection extends StatelessWidget {
  const SupportChatInputSection({
    super.key,
    required this.controller,
    required this.onSend,
    required this.enabled,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Material(
      color: StaticColors.white,
      child: Container(
        padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottom),
        decoration: const BoxDecoration(
          color: StaticColors.white,
          border: Border(top: BorderSide(color: StaticColors.cE2E2E2)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyle.regular14(context, color: StaticColors.black),
                decoration: InputDecoration(
                  hintText: 'Type...',
                  hintStyle: AppTextStyle.regular14(context, color: StaticColors.cBDC1C6),
                  prefixIcon: Icon(Icons.emoji_emotions_outlined, color: StaticColors.c666666.withValues(alpha: 0.7), size: 22),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  filled: true,
                  fillColor: StaticColors.white,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: StaticColors.primary, width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: const BorderSide(color: StaticColors.primary, width: 1.4),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide(color: StaticColors.cE2E2E2, width: 1),
                  ),
                ),
                onSubmitted: enabled ? (_) => onSend() : null,
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: enabled ? StaticColors.primary : StaticColors.cD1D1D1,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: enabled ? onSend : null,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(Icons.send_rounded, color: StaticColors.white, size: 22),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
