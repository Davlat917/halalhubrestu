import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/custom_button.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/core/widgets/network_image_chache.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_order_detail_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_orders_item.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_status.dart';

class OrderDetailSheet extends StatefulWidget {
  const OrderDetailSheet({
    super.key,
    required this.order,
    this.scrollController,
    this.expandBody = true,
    this.onAccept,
    this.acceptLoading = false,
  });

  final VendorOrderDetailModel order;
  final ScrollController? scrollController;
  final bool expandBody;
  final Future<void> Function(List<int> unavailableItemIds)? onAccept;
  final bool acceptLoading;

  @override
  State<OrderDetailSheet> createState() => _OrderDetailSheetState();
}

class _OrderDetailSheetState extends State<OrderDetailSheet> {
  late final List<ValueNotifier<bool>> _availableByIndex;

  bool get _canDecide {
    if (widget.onAccept == null) return false;
    final status = VendorOrdersItem.statusFromApi(widget.order.status);
    return status == VendorOrderStatus.newOrder;
  }

  @override
  void initState() {
    super.initState();
    _availableByIndex = [
      for (final item in widget.order.items)
        ValueNotifier<bool>(!item.isUnavailable),
    ];
  }

  @override
  void dispose() {
    for (final notifier in _availableByIndex) {
      notifier.dispose();
    }
    super.dispose();
  }

  Future<void> _onAcceptPressed() async {
    final onAccept = widget.onAccept;
    if (onAccept == null || widget.acceptLoading) return;

    final unavailable = <int>[];
    var toggledOffCount = 0;
    for (var i = 0; i < widget.order.items.length; i++) {
      if (_availableByIndex[i].value) continue;
      toggledOffCount++;
      final id = widget.order.items[i].id;
      if (id > 0) unavailable.add(id);
    }

    // Switches off but API item ids missing → empty ids would wrongly full-confirm.
    if (toggledOffCount > 0 && unavailable.length != toggledOffCount) {
      getIt<Display>().error(
        TranslationKeys.ordersItemIdsMissing.tr(context: context),
      );
      return;
    }

    await onAccept(unavailable);
  }

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
    final customerType = widget.order.isPickup
        ? TranslationKeys.ordersCustomerPickup.tr(context: context)
        : TranslationKeys.ordersCustomerDriver.tr(context: context);
    final showAccept = _canDecide;

    final itemsGrid = LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        const runSpacing = 12.0;
        final cardWidth =
            (constraints.maxWidth - spacing * (gridColumns - 1)) / gridColumns;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: [
            for (var i = 0; i < widget.order.items.length; i++)
              SizedBox(
                width: cardWidth,
                child: OrderDetailItemCard(
                  item: widget.order.items[i],
                  availabilityNotifier:
                      showAccept ? _availableByIndex[i] : null,
                  readOnlyAvailable: showAccept
                      ? null
                      : !widget.order.items[i].isUnavailable,
                ),
              ),
          ],
        );
      },
    );

    final summary = OrderDetailSummaryPanel(
      notes: widget.order.comment,
      customerType: customerType,
      paymentStatus: widget.order.paymentStatus,
      total: widget.order.totalPrice,
      showAccept: showAccept,
      acceptLoading: widget.acceptLoading,
      pinAcceptToBottom: isWide,
      onAccept: _onAcceptPressed,
    );

    final body = isWide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  child: itemsGrid,
                ),
              ),
              const SizedBox(width: 16),
              const VerticalDivider(width: 1, color: StaticColors.cE2E2E2),
              const SizedBox(width: 16),
              SizedBox(width: 250, child: summary),
            ],
          )
        : ListView(
            controller: widget.scrollController,
            children: [
              itemsGrid,
              const SizedBox(height: 14),
              summary,
            ],
          );

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                TranslationKeys.ordersDetailTitle.tr(context: context),
                style: AppTextStyle.semibold20(context),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(child: body),
      ],
    );

    if (widget.expandBody) {
      return SafeArea(
        child: Padding(padding: const EdgeInsets.all(16), child: content),
      );
    }

    return SizedBox(
      width: size.width * 0.92,
      height: size.height * 0.85,
      child: Padding(padding: const EdgeInsets.all(16), child: content),
    );
  }
}

class OrderDetailItemCard extends StatelessWidget {
  const OrderDetailItemCard({
    super.key,
    required this.item,
    this.availabilityNotifier,
    this.readOnlyAvailable,
  });

  final VendorOrderDetailItemModel item;
  final ValueNotifier<bool>? availabilityNotifier;

  /// When set (and [availabilityNotifier] is null), switch is shown read-only.
  final bool? readOnlyAvailable;

  @override
  Widget build(BuildContext context) {
    final description = item.description.trim();
    final category = item.category.trim();
    const imageHeight = 120.0;
    final showSwitch =
        availabilityNotifier != null || readOnlyAvailable != null;
    final isUnavailableVisual = availabilityNotifier == null
        ? (readOnlyAvailable == false || item.isUnavailable)
        : false;

    return Opacity(
      opacity: isUnavailableVisual ? 0.55 : 1,
      child: Container(
        decoration: BoxDecoration(
          color: StaticColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnavailableVisual
                ? StaticColors.cFF4E4E.withValues(alpha: 0.45)
                : StaticColors.cE2E2E2,
          ),
          boxShadow: [
            BoxShadow(
              color: StaticColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(14),
              ),
              child: SizedBox(
                height: imageHeight,
                child: item.image.isEmpty
                    ? const ColoredBox(color: StaticColors.white)
                    : NetworkImageCache(
                        imgUrl: item.image,
                        heightH: imageHeight,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.product,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyle.medium16(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatItemPrice(item.price),
                        style: AppTextStyle.medium14(
                          context,
                          color: StaticColors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.regular12(
                        context,
                        color: StaticColors.c9AA0A6,
                      ),
                    ),
                  ],
                  if (category.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      category,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.regular12(
                        context,
                        color: StaticColors.c9AA0A6,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${TranslationKeys.ordersAmount.tr(context: context)}: ${item.quantity}',
                          style: AppTextStyle.medium14(context),
                        ),
                      ),
                      if (showSwitch) _availabilitySwitch(context),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _availabilitySwitch(BuildContext context) {
    if (availabilityNotifier != null) {
      return ValueListenableBuilder<bool>(
        valueListenable: availabilityNotifier!,
        builder: (context, available, _) {
          return Transform.scale(
            scale: 0.9,
            alignment: Alignment.centerRight,
            child: Switch(
              value: available,
              activeThumbColor: StaticColors.white,
              activeTrackColor: StaticColors.primary,
              inactiveThumbColor: StaticColors.white,
              inactiveTrackColor: StaticColors.cD1D1D1,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              onChanged: (value) => availabilityNotifier!.value = value,
            ),
          );
        },
      );
    }

    final available = readOnlyAvailable ?? !item.isUnavailable;
    return Transform.scale(
      scale: 0.9,
      alignment: Alignment.centerRight,
      child: Switch(
        value: available,
        activeThumbColor: StaticColors.white,
        activeTrackColor: StaticColors.primary,
        inactiveThumbColor: StaticColors.white,
        inactiveTrackColor: StaticColors.cD1D1D1,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onChanged: null,
      ),
    );
  }

  String _formatItemPrice(String price) {
    final trimmed = price.trim();
    if (trimmed.isEmpty) return '';
    if (trimmed.contains(r'$')) return trimmed;
    return '$trimmed\$';
  }
}

class OrderDetailSummaryPanel extends StatelessWidget {
  const OrderDetailSummaryPanel({
    super.key,
    required this.notes,
    required this.customerType,
    required this.paymentStatus,
    required this.total,
    this.showAccept = false,
    this.acceptLoading = false,
    this.pinAcceptToBottom = false,
    this.onAccept,
  });

  final String notes;
  final String customerType;
  final String paymentStatus;
  final String total;
  final bool showAccept;
  final bool acceptLoading;
  final bool pinAcceptToBottom;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    Widget infoRow(
      String label,
      String value, {
      Color? valueColor,
      bool emphasize = false,
      bool valueBold = false,
    }) {
      final labelStyle = emphasize
          ? AppTextStyle.semibold14(context)
          : AppTextStyle.medium14(context);
      final valueStyle = emphasize
          ? AppTextStyle.semibold16(context)
          : valueBold
          ? AppTextStyle.medium16(context, color: valueColor)
          : AppTextStyle.regular16(
              context,
              color: valueColor ?? StaticColors.black,
            );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: Text('$label:', style: labelStyle)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value, textAlign: TextAlign.end, style: valueStyle),
            ),
          ],
        ),
      );
    }

    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TranslationKeys.ordersSpecialNotes.tr(context: context),
          style: AppTextStyle.semibold16(context),
        ),
        const SizedBox(height: 8),
        Text(
          notes.isEmpty ? '-' : notes,
          style: AppTextStyle.regular14(context, color: StaticColors.c9AA0A6),
        ),
        const SizedBox(height: 12),
        infoRow(
          TranslationKeys.ordersCustomerType.tr(context: context),
          customerType,
        ),
        infoRow(
          TranslationKeys.ordersPaymentStatus.tr(context: context),
          paymentStatus,
          valueColor: StaticColors.primary,
          valueBold: true,
        ),
        const Divider(height: 1, color: StaticColors.cE2E2E2),
        infoRow(
          TranslationKeys.ordersTotalPrice.tr(context: context),
          _formatTotal(total),
          emphasize: true,
        ),
      ],
    );

    final acceptButton = showAccept
        ? CustomButton(
            label: TranslationKeys.orderActionAccept.tr(context: context),
            backgroundColor: StaticColors.primary,
            foregroundColor: StaticColors.white,
            isLoading: acceptLoading,
            borderRadius: 12,
            width: double.infinity,
            onPressed: acceptLoading ? null : onAccept,
          )
        : null;

    if (!pinAcceptToBottom) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          details,
          if (acceptButton != null) ...[
            const SizedBox(height: 16),
            acceptButton,
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: SingleChildScrollView(child: details)),
        if (acceptButton != null) ...[
          const SizedBox(height: 16),
          acceptButton,
        ],
      ],
    );
  }

  String _formatTotal(String total) {
    final trimmed = total.trim();
    if (trimmed.isEmpty) return r'$0';
    if (trimmed.contains(r'$')) return trimmed;
    return '\$$trimmed';
  }
}
