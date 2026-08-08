import 'dart:async';

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_status.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_ui_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/order_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/widgets/order_progress_tracker.dart';

class VendorOrderCard extends StatefulWidget {
  const VendorOrderCard({
    super.key,
    required this.order,
    this.onConfirm,
    this.onCancel,
    this.onReady,
    this.onCompleted,
    this.onMore,
    this.onAwaitingExpired,
    this.onDismissCustomerBanner,
  });

  final VendorOrderUiModel order;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final VoidCallback? onReady;
  final VoidCallback? onCompleted;
  final VoidCallback? onMore;
  final VoidCallback? onAwaitingExpired;
  final VoidCallback? onDismissCustomerBanner;

  @override
  State<VendorOrderCard> createState() => _VendorOrderCardState();
}

class _VendorOrderCardState extends State<VendorOrderCard> {
  Timer? _ticker;
  bool _expiryNotified = false;

  VendorOrderUiModel get order => widget.order;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(covariant VendorOrderCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.status != order.status ||
        oldWidget.order.awaitingStartedAt != order.awaitingStartedAt) {
      _expiryNotified = false;
      _syncTicker();
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _syncTicker() {
    _ticker?.cancel();
    if (order.status != VendorOrderStatus.awaitingCustomer) return;
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {});
      if (!_expiryNotified && order.isAwaitingExpired) {
        _expiryNotified = true;
        widget.onAwaitingExpired?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final terminal = order.isTerminal;
    final waiting = order.status == VendorOrderStatus.awaitingCustomer;
    final continued = order.isCustomerContinued;
    final borderColor = waiting || continued
        ? StaticColors.primary
        : StaticColors.cE2E2E2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (order.showCustomerContinuedBanner)
          _customerContinuedInfoBanner(context),
        Material(
          color: StaticColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: borderColor),
          ),
          shadowColor: StaticColors.black.withValues(alpha: 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (waiting || continued) _statusHeaderBar(context),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            '#${order.id}',
                            style: AppTextStyle.bold16(context),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 16,
                              color: StaticColors.c9AA0A6,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                order.createdAtLabel,
                                style: AppTextStyle.regular12(
                                  context,
                                  color: StaticColors.c9AA0A6,
                                ),
                                textAlign: TextAlign.end,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (!terminal)
                      ..._activeStatusAndProgress(context)
                    else
                      const SizedBox(height: 12),
                    Text(
                      order.itemsSummary,
                      style: AppTextStyle.regular14(
                        context,
                        color: StaticColors.c4C4C4C,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(order.totalLabel, style: AppTextStyle.bold16(context)),
                    const SizedBox(height: 14),
                    _wrapWithDetailAside(context, _actions(context)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _customerContinuedInfoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: StaticColors.primary.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: StaticColors.primary.withValues(alpha: 0.35),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle, color: StaticColors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TranslationKeys.ordersCustomerContinuedBannerTitle.tr(
                        context: context,
                      ),
                      style: AppTextStyle.semibold14(
                        context,
                        color: StaticColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      TranslationKeys.ordersCustomerContinuedBanner.tr(
                        context: context,
                        namedArgs: {'orderNumber': order.id},
                      ),
                      style: AppTextStyle.regular12(context),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: widget.onDismissCustomerBanner,
                icon: const Icon(Icons.close_rounded, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusHeaderBar(BuildContext context) {
    final waiting = order.status == VendorOrderStatus.awaitingCustomer;
    final label = waiting
        ? TranslationKeys.ordersWaitingForCustomer.tr(
            context: context,
            namedArgs: {'time': order.awaitingRemainingLabel},
          )
        : TranslationKeys.ordersCustomerConfirmedContinue.tr(context: context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: StaticColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
      ),
      child: Text(
        label,
        style: AppTextStyle.semibold12(context, color: StaticColors.white),
        textAlign: TextAlign.center,
      ),
    );
  }

  List<Widget> _activeStatusAndProgress(BuildContext context) {
    final (badgeBg, badgeFg, label, accent) = _badgeStyle(
      context,
      order.status,
    );
    return [
      const SizedBox(height: 10),
      Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeBg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: AppTextStyle.semibold12(context, color: badgeFg),
          ),
        ),
      ),
      const SizedBox(height: 14),
      OrderProgressTracker(
        activeNodes: order.progressNodesActive,
        activeColor: accent,
      ),
      const SizedBox(height: 14),
    ];
  }

  (Color bg, Color fg, String text, Color accent) _badgeStyle(
    BuildContext context,
    VendorOrderStatus s,
  ) {
    switch (s) {
      case VendorOrderStatus.newOrder:
        return (
          OrderColors.newBadgeBg,
          OrderColors.actionBlue,
          TranslationKeys.orderStatusNew.tr(context: context),
          OrderColors.actionBlue,
        );
      case VendorOrderStatus.awaitingCustomer:
        return (
          OrderColors.newBadgeBg,
          OrderColors.actionBlue,
          TranslationKeys.orderStatusNew.tr(context: context),
          OrderColors.actionBlue,
        );
      case VendorOrderStatus.accepted:
        return (
          OrderColors.acceptedBadgeBg,
          OrderColors.warningOrange,
          TranslationKeys.orderStatusAccepted.tr(context: context),
          OrderColors.warningOrange,
        );
      case VendorOrderStatus.ready:
        return (
          OrderColors.readyBadgeBg,
          OrderColors.success,
          TranslationKeys.orderStatusReady.tr(context: context),
          OrderColors.success,
        );
      case VendorOrderStatus.completed:
      case VendorOrderStatus.delivered:
      case VendorOrderStatus.canceled:
      case VendorOrderStatus.deliveryFailed:
        throw StateError('Terminal status has no badge');
    }
  }

  Widget _wrapWithDetailAside(BuildContext context, Widget actions) {
    if (widget.onMore == null) return actions;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _detailAsideButton(context),
        const SizedBox(width: 8),
        Expanded(child: actions),
      ],
    );
  }

  Widget _actions(BuildContext context) {
    switch (order.status) {
      case VendorOrderStatus.completed:
      case VendorOrderStatus.delivered:
        return _terminalStatusRow(
          context,
          background: OrderColors.doneStripBg,
          foreground: OrderColors.success,
          icon: Icons.done_all_rounded,
          label: TranslationKeys.orderStatusDone.tr(context: context),
        );
      case VendorOrderStatus.canceled:
        return _terminalStatusRow(
          context,
          background: OrderColors.canceledStripBg,
          foreground: OrderColors.danger,
          icon: Icons.block_rounded,
          label: TranslationKeys.orderStatusCancelled.tr(context: context),
        );
      case VendorOrderStatus.deliveryFailed:
        return _terminalStatusRow(
          context,
          background: OrderColors.deliveryFailedStripBg,
          foreground: OrderColors.warningOrange,
          icon: Icons.error_outline_rounded,
          label: TranslationKeys.orderStatusDeliveryFailed.tr(context: context),
        );
      case VendorOrderStatus.newOrder:
        return Row(
          children: [
            Expanded(
              child: _filledAction(
                context,
                label: TranslationKeys.orderActionConfirm.tr(context: context),
                icon: Icons.check_rounded,
                bg: OrderColors.actionBlue,
                onTap: widget.onConfirm,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _filledAction(
                context,
                label: TranslationKeys.cancel.tr(context: context),
                icon: Icons.block_rounded,
                bg: OrderColors.danger,
                onTap: widget.onCancel,
              ),
            ),
          ],
        );
      case VendorOrderStatus.awaitingCustomer:
        // Not accepted yet — same Confirm/Cancel chrome; Confirm waits on customer.
        return Row(
          children: [
            Expanded(
              child: _filledAction(
                context,
                label: TranslationKeys.orderActionConfirm.tr(context: context),
                icon: Icons.check_rounded,
                bg: OrderColors.actionBlue.withValues(alpha: 0.45),
                onTap: null,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _filledAction(
                context,
                label: TranslationKeys.cancel.tr(context: context),
                icon: Icons.block_rounded,
                bg: OrderColors.danger,
                onTap: widget.onCancel,
              ),
            ),
          ],
        );
      case VendorOrderStatus.accepted:
        return Row(
          children: [
            Expanded(
              child: _filledAction(
                context,
                label: TranslationKeys.orderActionReady.tr(context: context),
                icon: Icons.auto_awesome_rounded,
                bg: OrderColors.warningOrange,
                onTap: widget.onReady,
              ),
            ),
          ],
        );
      case VendorOrderStatus.ready:
        return Row(
          children: [
            Expanded(
              child: _filledAction(
                context,
                label: TranslationKeys.orderActionCompleted.tr(
                  context: context,
                ),
                icon: Icons.done_all_rounded,
                bg: OrderColors.success,
                onTap: widget.onCompleted,
              ),
            ),
          ],
        );
    }
  }

  Widget _terminalStatusRow(
    BuildContext context, {
    required Color background,
    required Color foreground,
    required IconData icon,
    required String label,
  }) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: foreground),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: AppTextStyle.semibold14(
                  context,
                  color: foreground,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filledAction(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color bg,
    required VoidCallback? onTap,
  }) {
    return FilledButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: StaticColors.white),
      label: Text(
        label,
        style: AppTextStyle.semibold14(context, color: StaticColors.white),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: StaticColors.white,
        disabledBackgroundColor: bg,
        disabledForegroundColor: StaticColors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Widget _detailAsideButton(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: OutlinedButton(
        onPressed: widget.onMore,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          side: const BorderSide(color: StaticColors.cE0E0E0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          foregroundColor: StaticColors.c666666,
          backgroundColor: StaticColors.white,
        ),
        child: const Icon(Icons.menu_rounded, size: 22),
      ),
    );
  }
}
