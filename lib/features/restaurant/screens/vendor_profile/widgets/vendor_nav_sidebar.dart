import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_profile/navigation/vendor_nav_item.dart';

/// Chap menyu: mobil [Drawer] va tablet doimiy sidebar uchun bir xil UI.
class VendorNavSidebar extends StatelessWidget {
  const VendorNavSidebar({
    super.key,
    required this.selected,
    required this.onItemTap,
    this.horizontalPadding = 12,
    this.footer,
  });

  final VendorNavItem selected;
  final ValueChanged<VendorNavItem> onItemTap;
  final double horizontalPadding;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: StaticColors.white,
      child: SafeArea(
        right: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            16,
            horizontalPadding,
            16,
          ),
          children: [
            for (final item in VendorNavItemX.ordered)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _NavTile(
                  item: item,
                  selected: selected == item,
                  onTap: () => onItemTap(item),
                ),
              ),
            ?footer,
          ],
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final VendorNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bg = selected ? StaticColors.primary : StaticColors.transparent;
    final fg = selected ? StaticColors.white : StaticColors.c666666;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              item.icon.svg(
                height: 22,
                colorFilter: ColorFilter.mode(fg, BlendMode.srcIn),
              ),
              // Icon(item.icon, size: 22, color: fg),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.label(context),
                  style: AppTextStyle.semibold14(context, color: fg),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
