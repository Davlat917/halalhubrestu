import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/extensions/size_extension.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';

class DayHoursTile extends StatelessWidget {
  const DayHoursTile({
    super.key,
    required this.availableWidth,
    required this.day,
    required this.isOpen,
    required this.onChanged,
    required this.startTime,
    required this.endTime,
    required this.onPickStart,
    required this.onPickEnd,
  });

  final double availableWidth;
  final String day;
  final bool isOpen;
  final ValueChanged<bool> onChanged;
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final VoidCallback onPickStart;
  final VoidCallback onPickEnd;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.wOf(10, availableWidth)),
      padding: EdgeInsets.all(context.wOf(10, availableWidth)),
      decoration: BoxDecoration(
        color: StaticColors.cF8F8F8,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: StaticColors.cE0E0E0),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  day,
                  style: AppTextStyle.medium16(context, aW: availableWidth),
                ),
              ),
              Text(
                isOpen ? 'Open' : 'Close',
                style: AppTextStyle.regular14(
                  context,
                  aW: availableWidth,
                  color: isOpen ? StaticColors.primary : StaticColors.c9AA0A6,
                ),
              ),
              Switch(
                value: isOpen,
                onChanged: onChanged,
                activeThumbColor: StaticColors.primary,
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: _timeBox(
                  context,
                  isOpen,
                  _formatTime(startTime),
                  onTap: onPickStart,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: context.wOf(8, availableWidth),
                ),
                child: Text(
                  'to',
                  style: AppTextStyle.regular14(context, aW: availableWidth),
                ),
              ),
              Expanded(
                child: _timeBox(
                  context,
                  isOpen,
                  _formatTime(endTime),
                  onTap: onPickEnd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final ampm = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  Widget _timeBox(
    BuildContext context,
    bool enabled,
    String value, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: enabled ? StaticColors.white : StaticColors.cF0F0F0,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? StaticColors.primary.withAlpha(140)
                : StaticColors.cDADADA,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: AppTextStyle.regular14(
                  context,
                  aW: availableWidth,
                  color: enabled ? StaticColors.black : StaticColors.c9AA0A6,
                ),
              ),
            ),
            Icon(
              Icons.expand_more,
              size: 18,
              color: enabled ? StaticColors.black54 : StaticColors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
