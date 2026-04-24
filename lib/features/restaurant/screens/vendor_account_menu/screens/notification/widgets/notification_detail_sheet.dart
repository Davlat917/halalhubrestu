import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/data/models/notification_item_model.dart';

Widget _buildImageBlock(BuildContext context, NotificationItemModel item, double width) {
  if (item.image.isEmpty || width <= 0) return const SizedBox.shrink();
  final height = width * 9 / 16;
  return ClipRRect(
    borderRadius: BorderRadius.circular(14),
    child: SizedBox(
      width: width,
      height: height,
      child: CachedNetworkImage(
        imageUrl: item.image,
        fit: BoxFit.cover,
        placeholder: (_, _) => ColoredBox(
          color: StaticColors.cF0F0F0,
          child: const Center(child: CircularProgressIndicator(color: StaticColors.primary)),
        ),
        errorWidget: (_, _, _) => ColoredBox(
          color: StaticColors.cF0F0F0,
          child: Icon(Icons.image_not_supported_outlined, color: StaticColors.c9AA0A6, size: 48),
        ),
      ),
    ),
  );
}

Widget _buildMessageBlock(BuildContext context, NotificationItemModel item) {
  return DecoratedBox(
    decoration: BoxDecoration(
      color: StaticColors.cF4F4F4,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Padding(
      padding: const EdgeInsets.all(14),
      child: Text(
        item.message,
        style: AppTextStyle.regular14(context, color: StaticColors.c4C4C4C).copyWith(height: 1.45),
      ),
    ),
  );
}

/// [contentWidth] — ichki kontent kengligi (padding tashqarida).
List<Widget> _detailItems(BuildContext context, NotificationItemModel item, double contentWidth) {
  return [
    if (item.image.isNotEmpty) ...[
      _buildImageBlock(context, item, contentWidth),
      const SizedBox(height: 16),
    ],
    _buildMessageBlock(context, item),
  ];
}

Future<void> showNotificationDetailSheet(BuildContext context, NotificationItemModel item) {
  if (!ResponsiveSection.isMobileLayout(context)) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final size = MediaQuery.sizeOf(ctx);
        final maxH = size.height * 0.85;
        final horizontalInset = 40.0;
        final dialogW = math.min(520.0, math.max(280.0, size.width - horizontalInset * 2));
        const pad = 20.0;
        final contentW = dialogW - pad * 2;

        return Dialog(
          backgroundColor: StaticColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: EdgeInsets.symmetric(horizontal: horizontalInset, vertical: 24),
          child: SizedBox(
            width: dialogW,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxH),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(pad),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      item.title,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.semibold18(ctx, size: 18, color: StaticColors.black),
                    ),
                    const SizedBox(height: 12),
                    ..._detailItems(ctx, item, contentW),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return DraggableScrollableSheet(
        initialChildSize: 0.72,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: StaticColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: StaticColors.cD1D1D1, borderRadius: BorderRadius.circular(2)),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    item.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyle.semibold18(context, size: 18, color: StaticColors.black),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const listPadH = 20.0;
                      final contentW = math.max(0.0, constraints.maxWidth - listPadH * 2);
                      return ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(listPadH, 0, listPadH, 24),
                        children: _detailItems(context, item, contentW),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
