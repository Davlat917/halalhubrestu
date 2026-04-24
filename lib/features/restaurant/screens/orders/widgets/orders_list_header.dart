import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/common_textfield.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/order_colors.dart';
import 'package:halalhub_restaurant/gen/assets.gen.dart';

/// Sarlavha + kengayadigan qidiruv ([searchController] bo‘lsa) + ixtiyoriy «Order history».
class OrdersListHeader extends StatelessWidget {
  const OrdersListHeader({super.key, required this.horizontalPadding, this.title = TranslationKeys.ordersTitle, this.onOrderHistoryTap, this.searchController, this.searchExpanded = false, this.onSearchOpen, this.onSearchClose, this.onSearchQueryChanged});

  final double horizontalPadding;
  final String title;
  final VoidCallback? onOrderHistoryTap;
  final TextEditingController? searchController;
  final bool searchExpanded;
  final VoidCallback? onSearchOpen;
  final VoidCallback? onSearchClose;
  final VoidCallback? onSearchQueryChanged;

  @override
  Widget build(BuildContext context) {
    final hasSearch = searchController != null && onSearchOpen != null && onSearchClose != null;

    return Material(
      color: StaticColors.cF8F8F8,
      child: Padding(
        padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!searchExpanded || !hasSearch)
              Expanded(
                child: Text(
                  title.tr(context: context),
                  style: AppTextStyle.semibold18(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (searchExpanded && hasSearch) ...[
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: CommonTextField(
                    controller: searchController,
                    autofocus: true,
                    onChanged: (_) => onSearchQueryChanged?.call(),
                    hint: TranslationKeys.orderId.tr(context: context),
                    textSize: 14,
                    radius: 50,
                    availableWidth: MediaQuery.sizeOf(context).width,
                    background: StaticColors.white,
                    enabledBorderColor: StaticColors.cE0E0E0,
                    focusedBorderColor: OrderColors.success,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: () {
                  searchController!.clear();
                  onSearchClose!();
                  onSearchQueryChanged?.call();
                },
                icon: const Icon(Icons.close_rounded, color: StaticColors.c666666),
              ),
            ],
            if (!searchExpanded && hasSearch) ...[
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: onSearchOpen,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  maximumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: StaticColors.cE0E0E0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  foregroundColor: StaticColors.c4C4C4C,
                  backgroundColor: StaticColors.white,
                ),
                child: Assets.icons.searchIcon.svg(width: 22, height: 22, fit: BoxFit.contain, colorFilter: const ColorFilter.mode(StaticColors.black, BlendMode.srcIn)),
              ),
            ],
            if (!hasSearch) ...[
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(TranslationKeys.searchSoon.tr(context: context))));
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(44, 44),
                  maximumSize: const Size(44, 44),
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  side: const BorderSide(color: StaticColors.cE0E0E0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  foregroundColor: StaticColors.c4C4C4C,
                  backgroundColor: StaticColors.white,
                ),
                child: Assets.icons.searchIcon.svg(width: 22, height: 22, fit: BoxFit.contain, colorFilter: const ColorFilter.mode(StaticColors.black, BlendMode.srcIn)),
              ),
            ],
            if (onOrderHistoryTap != null) ...[
              const SizedBox(width: 8),
              FilledButton(
                onPressed: onOrderHistoryTap,
                style: FilledButton.styleFrom(
                  backgroundColor: OrderColors.success,
                  foregroundColor: StaticColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: Text(
                  TranslationKeys.orderHistory.tr(context: context),
                  style: AppTextStyle.semibold14(context, color: StaticColors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
