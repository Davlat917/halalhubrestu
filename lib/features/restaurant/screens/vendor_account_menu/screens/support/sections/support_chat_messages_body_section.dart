import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/data/models/service_support_chat_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/widgets/support_chat_date_chip.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/widgets/support_chat_message_bubble.dart';

class SupportChatMessagesBodySection extends StatelessWidget {
  const SupportChatMessagesBodySection({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  final List<Message> messages;
  final ScrollController scrollController;

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  List<Widget> _buildItems() {
    final items = <Widget>[];
    DateTime? lastDay;
    for (final msg in messages) {
      final ts = msg.timestamp?.toLocal();
      if (ts != null) {
        final day = DateTime(ts.year, ts.month, ts.day);
        if (lastDay == null || !_sameDay(lastDay, day)) {
          items.add(SupportChatDateChip(date: day));
          lastDay = day;
        }
      }
      items.add(SupportChatMessageBubble(message: msg));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          TranslationKeys.supportStartConversation.tr(context: context),
          style: TextStyle(color: StaticColors.c666666.withValues(alpha: 0.6)),
        ),
      );
    }
    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      children: _buildItems(),
    );
  }
}
