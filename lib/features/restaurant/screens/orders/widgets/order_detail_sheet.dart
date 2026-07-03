import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/network_image_chache.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_order_detail_model.dart';

class OrderDetailSheet extends StatelessWidget {
  const OrderDetailSheet({
    super.key,
    required this.order,
    this.scrollController,
    this.expandBody = true,
  });

  final VendorOrderDetailModel order;
  final ScrollController? scrollController;
  final bool expandBody;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final orientation = MediaQuery.orientationOf(context);
    final isMobile = ResponsiveSection.isMobileLayout(context);
    final isTablet =
        size.shortestSide >= ResponsiveSection.mobileBreakpoint &&
        size.width < ResponsiveSection.desktopBreakpoint;
    final isWide = !ResponsiveSection.isMobileLayout(context);
    final gridColumns = isTablet
        ? (orientation == Orientation.landscape ? 3 : 2)
        : (isMobile ? 2 : 3);
    final customerType = order.isPickup
        ? TranslationKeys.ordersCustomerPickup.tr(context: context)
        : TranslationKeys.ordersCustomerDriver.tr(context: context);

    final leftContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          TranslationKeys.ordersDetailTitle.tr(context: context),
          style: AppTextStyle.semibold20(context),
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 10.0;
            const runSpacing = 12.0;
            final cardWidth =
                (constraints.maxWidth - spacing * (gridColumns - 1)) /
                gridColumns;
            return Wrap(
              spacing: spacing,
              runSpacing: runSpacing,
              children: [
                for (final item in order.items)
                  SizedBox(
                    width: cardWidth,
                    child: OrderDetailItemCard(item: item),
                  ),
              ],
            );
          },
        ),
      ],
    );

    final summary = OrderDetailSummaryPanel(
      notes: order.comment,
      customerType: customerType,
      paymentStatus: order.paymentStatus,
      total: order.totalPrice,
    );
    final body = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: leftContent,
                ),
              ),
              const SizedBox(width: 16),
              const VerticalDivider(width: 1, color: StaticColors.cE2E2E2),
              const SizedBox(width: 16),
              SizedBox(width: 250, child: summary),
            ],
          )
        : ListView(
            controller: scrollController,
            shrinkWrap: true,
            children: [leftContent, const SizedBox(height: 14), summary],
          );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: expandBody ? MainAxisSize.max : MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '#${order.displayOrderNumber}',
                    style: AppTextStyle.semibold18(
                      context,
                      color: StaticColors.c666666,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (expandBody)
              Expanded(child: body)
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.72,
                ),
                child: body,
              ),
          ],
        ),
      ),
    );
  }
}

class OrderDetailItemCard extends StatelessWidget {
  const OrderDetailItemCard({super.key, required this.item});

  final VendorOrderDetailItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: SizedBox(
              height: 110,
              child: item.image.isEmpty
                  ? const ColoredBox(color: StaticColors.white)
                  : NetworkImageCache(
                      imgUrl: item.image,
                      heightH: 110,
                      radius: 0,
                      fit: BoxFit.cover,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.product,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.medium16(context),
                      ),
                    ),
                    Text(
                      '\$${item.price}',
                      style: AppTextStyle.medium14(
                        context,
                        color: StaticColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${TranslationKeys.ordersAmount.tr(context: context)}: ${item.quantity}',
                  style: AppTextStyle.bold16(context),
                ),
                if (item.modifiers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1, color: StaticColors.cE2E2E2),
                  const SizedBox(height: 8),
                  Text(
                    _formatModifiersLine(item.modifiers),
                    style: AppTextStyle.regular12(context),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatModifiersLine(List<VendorOrderDetailModifierModel> modifiers) {
    final parts = <String>[];
    for (final modifier in modifiers) {
      final token = _modifierLabel(modifier);
      if (token.isNotEmpty) parts.add(token);
    }
    return parts.join(', ');
  }

  String _modifierLabel(VendorOrderDetailModifierModel modifier) {
    final name = modifier.name.trim();
    if (name.isEmpty) return '';
    final price = modifier.price.trim();
    if (price.isEmpty || _isZeroPrice(price)) return name;
    return '$name + \$$price';
  }

  bool _isZeroPrice(String price) {
    final amount = double.tryParse(price);
    return amount == null || amount == 0.0;
  }
}

class OrderDetailSummaryPanel extends StatelessWidget {
  const OrderDetailSummaryPanel({
    super.key,
    required this.notes,
    required this.customerType,
    required this.paymentStatus,
    required this.total,
  });

  final String notes;
  final String customerType;
  final String paymentStatus;
  final String total;

  @override
  Widget build(BuildContext context) {
    Widget row(String l, String v, {Color? valueColor}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text('$l:', style: AppTextStyle.medium14(context))),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.end,
              style: AppTextStyle.regular16(
                context,
                color: valueColor ?? StaticColors.c666666,
              ),
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.ordersSpecialNotes.tr(context: context),
          style: AppTextStyle.medium16(context),
        ),
        const SizedBox(height: 6),
        Text(
          notes.isEmpty ? '-' : notes,
          style: AppTextStyle.regular14(context, color: StaticColors.c9AA0A6),
        ),
        const SizedBox(height: 10),
        const Divider(height: 1, color: StaticColors.cE2E2E2),
        row(
          TranslationKeys.ordersCustomerType.tr(context: context),
          customerType,
        ),
        const Divider(height: 1, color: StaticColors.cE2E2E2),
        row(
          TranslationKeys.ordersPaymentStatus.tr(context: context),
          paymentStatus,
          valueColor: StaticColors.primary,
        ),
        const Divider(height: 1, color: StaticColors.cE2E2E2),
        row(TranslationKeys.ordersTotalPrice.tr(context: context), '\$$total'),
        const Divider(height: 1, color: StaticColors.cE2E2E2),
      ],
    );
  }
}
