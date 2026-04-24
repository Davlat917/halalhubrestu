import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/data/models/service_support_chat_model.dart';

class SupportChatMessageBubble extends StatelessWidget {
  const SupportChatMessageBubble({super.key, required this.message});

  final Message message;

  static String formatTime(DateTime? dt) {
    if (dt == null) return '';
    final local = dt.toLocal();
    var h = local.hour;
    final m = local.minute.toString().padLeft(2, '0');
    final isPm = h >= 12;
    var h12 = h % 12;
    if (h12 == 0) h12 = 12;
    return '$h12:$m ${isPm ? 'PM' : 'AM'}';
  }

  @override
  Widget build(BuildContext context) {
    final fromUser = message.fromUser ?? false;
    final bg = fromUser ? StaticColors.cEAF8EF : StaticColors.cF0F0F0;
    final textColor = fromUser ? StaticColors.primary : StaticColors.black;
    final timeColor = fromUser ? StaticColors.primary.withValues(alpha: 0.75) : StaticColors.c666666;
    final align = fromUser ? Alignment.centerRight : Alignment.centerLeft;
    final content = message.content ?? '';
    final maxBubble = MediaQuery.sizeOf(context).width * 0.78;

    return Align(
      alignment: align,
      child: Container(
        constraints: BoxConstraints(maxWidth: maxBubble),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(fromUser ? 14 : 4),
            bottomRight: Radius.circular(fromUser ? 4 : 14),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: fromUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              content,
              softWrap: true,
              style: AppTextStyle.regular14(context, color: textColor),
            ),
            const SizedBox(height: 4),
            Text(
              formatTime(message.timestamp),
              style: AppTextStyle.regular12(context, size: 11, color: timeColor),
            ),
          ],
        ),
      ),
    );
  }
}
