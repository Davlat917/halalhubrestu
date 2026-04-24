import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/data/models/notification_item_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/widgets/notification_detail_sheet.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/widgets/notification_relative_time.dart';

class NotificationListTile extends StatelessWidget {
  const NotificationListTile({super.key, required this.item});

  final NotificationItemModel item;

  @override
  Widget build(BuildContext context) {
    final subtitle = notificationRelativeTime(context, item.createdAt);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showNotificationDetailSheet(context, item),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: StaticColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: StaticColors.cE2E2E2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: StaticColors.cEAF8EF,
                child: ClipOval(
                  child: item.icon.isEmpty
                      ? Icon(
                          Icons.notifications_none_rounded,
                          color: StaticColors.primary.withValues(alpha: 0.85),
                          size: 26,
                        )
                      : CachedNetworkImage(
                          imageUrl: item.icon,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => Icon(
                            Icons.notifications_none_rounded,
                            color: StaticColors.primary.withValues(alpha: 0.85),
                            size: 26,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title.isNotEmpty ? item.title : item.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.semibold18(
                        context,
                        size: 15,
                        color: StaticColors.black,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyle.regular12(
                          context,
                          color: StaticColors.c9AA0A6,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!item.isRead) ...[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: StaticColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
