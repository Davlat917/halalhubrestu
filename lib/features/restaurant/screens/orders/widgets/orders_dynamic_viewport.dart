import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/orders_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_ui_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/widgets/orders_empty_view.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/widgets/vendor_order_card.dart';

class OrdersDynamicViewport extends StatelessWidget {
  const OrdersDynamicViewport({
    super.key,
    required this.horizontalPad,
    required this.columnCount,
    required this.localUiVersionNotifier,
    required this.scrollController,
    required this.searchController,
    required this.visibleOrders,
    required this.onStatusChangeRequest,
    required this.ordersRepository,
  });

  final double horizontalPad;
  final int columnCount;
  final ValueListenable<int> localUiVersionNotifier;
  final ScrollController scrollController;
  final TextEditingController searchController;
  final List<VendorOrderUiModel> Function(List<VendorOrderUiModel>)
  visibleOrders;
  final void Function(VendorOrderUiModel order, String nextStatus)
  onStatusChangeRequest;
  final OrdersRepository ordersRepository;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: localUiVersionNotifier,
      builder: (context, _, _) {
        return BlocBuilder<OrdersBloc, OrdersState>(
          buildWhen: (prev, curr) =>
              prev.status != curr.status ||
              prev.items != curr.items ||
              prev.isLoadingMore != curr.isLoadingMore ||
              prev.errorMessage != curr.errorMessage,
          builder: (context, state) {
            if (state.status == OrdersLoadStatus.loading &&
                state.items.isEmpty) {
              return const Center(child: CircularProgressIndicator.adaptive());
            }
            if (state.status == OrdersLoadStatus.failure &&
                state.items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.errorMessage ??
                            TranslationKeys.ordersFailedLoad.tr(
                              context: context,
                            ),
                        textAlign: TextAlign.center,
                        style: AppTextStyle.regular14(
                          context,
                          color: StaticColors.c666666,
                        ),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () => context.read<OrdersBloc>().add(
                          const OrdersLoadRequested(),
                        ),
                        child: Text(TranslationKeys.retry.tr(context: context)),
                      ),
                    ],
                  ),
                ),
              );
            }

            final visible = visibleOrders(state.items);
            if (state.items.isEmpty ||
                (searchController.text.trim().isEmpty && visible.isEmpty)) {
              return const OrdersEmptyView();
            }

            if (visible.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    TranslationKeys.ordersNotFoundById.tr(context: context),
                    textAlign: TextAlign.center,
                    style: AppTextStyle.regular16(
                      context,
                      color: StaticColors.c666666,
                    ),
                  ),
                ),
              );
            }

            final Widget list;
            if (columnCount <= 1) {
              list = ListView.separated(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPad,
                  4,
                  horizontalPad,
                  24,
                ),
                itemCount: visible.length + (state.isLoadingMore ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  if (index >= visible.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  }
                  return _card(context, visible[index]);
                },
              );
            } else {
              final gridDataRows = (visible.length / columnCount).ceil();
              final gridItemCount =
                  gridDataRows + (state.isLoadingMore ? 1 : 0);
              list = ListView.builder(
                controller: scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  horizontalPad,
                  4,
                  horizontalPad,
                  24,
                ),
                itemCount: gridItemCount,
                itemBuilder: (context, row) {
                  if (row >= gridDataRows) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: CircularProgressIndicator.adaptive(),
                      ),
                    );
                  }
                  final i0 = row * columnCount;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var c = 0; c < columnCount; c++) ...[
                          if (c > 0) const SizedBox(width: 12),
                          Expanded(
                            child: i0 + c < visible.length
                                ? _card(context, visible[i0 + c])
                                : const SizedBox.shrink(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            }

            return RefreshIndicator(
              color: StaticColors.primary,
              onRefresh: () async {
                final bloc = context.read<OrdersBloc>();
                bloc.add(const OrdersRefreshRequested());
                await bloc.stream.firstWhere(
                  (s) => s.status != OrdersLoadStatus.loading,
                );
              },
              child: list,
            );
          },
        );
      },
    );
  }

  Widget _card(BuildContext context, VendorOrderUiModel order) {
    return VendorOrderCard(
      order: order,
      onConfirm: () => onStatusChangeRequest(order, 'confirmed'),
      onCancel: () => onStatusChangeRequest(order, 'cancelled'),
      onReady: () => onStatusChangeRequest(order, 'ready'),
      onCompleted: () {
        final statusForDone = order.isPickup ? 'completed' : 'delivered';
        onStatusChangeRequest(order, statusForDone);
      },
      onMore: () => _openOrderDetail(context, order),
    );
  }

  Future<void> _openOrderDetail(
    BuildContext context,
    VendorOrderUiModel order,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final rootNavigator = _navigatorOf(context);
    final detailLoadFailedText = TranslationKeys.ordersDetailFailedLoad.tr(
      context: context,
    );
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator.adaptive()),
    );
    Map<String, dynamic>? detail;
    try {
      detail = await ordersRepository.fetchOrderDetail(
        orderId: order.backendId,
      );
    } catch (_) {
      if (rootNavigator.canPop()) rootNavigator.pop();
      messenger?.showSnackBar(SnackBar(content: Text(detailLoadFailedText)));
      return;
    }
    if (rootNavigator.canPop()) rootNavigator.pop();
    if (!context.mounted) return;

    final isMobile = ResponsiveSection.isMobileLayout(context);
    if (!isMobile) {
      await showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          backgroundColor: StaticColors.white,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: _OrderDetailSheet(order: detail!, expandBody: false),
        ),
      );
      return;
    }
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: StaticColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) =>
            _OrderDetailSheet(order: detail!, scrollController: controller),
      ),
    );
  }
}

NavigatorState _navigatorOf(BuildContext context) =>
    Navigator.of(context, rootNavigator: true);

class _OrderDetailSheet extends StatelessWidget {
  const _OrderDetailSheet({
    required this.order,
    this.scrollController,
    this.expandBody = true,
  });

  final Map<String, dynamic> order;
  final ScrollController? scrollController;
  final bool expandBody;

  @override
  Widget build(BuildContext context) {
    final items = (order['items'] is List)
        ? (order['items'] as List)
        : const [];
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
    final aspectRatio = isTablet
        ? (orientation == Orientation.landscape ? 0.88 : 0.8)
        : (isMobile ? 0.7 : 0.7);
    final orderType = (order['order_type'] ?? '').toString();
    final paymentType = (order['payment_type'] ?? '').toString();
    final paymentStatus = (order['payment_status'] ?? '').toString();
    final total = (order['total_price'] ?? '').toString();
    final notes = (order['comment'] ?? '').toString();
    final customerType = orderType.toLowerCase() == 'pickup'
        ? TranslationKeys.ordersCustomerPickup.tr(context: context)
        : TranslationKeys.ordersCustomerDriver.tr(context: context);

    Widget leftContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          TranslationKeys.ordersDetailTitle.tr(context: context),
          style: AppTextStyle.semibold20(context),
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridColumns,
            crossAxisSpacing: 10,
            mainAxisSpacing: 12,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (_, i) => _DetailItemCard(item: items[i]),
        ),
      ],
    );

    final summary = _OrderDetailSummaryPanel(
      notes: notes,
      customerType: customerType,
      paymentType: paymentType,
      paymentStatus: paymentStatus,
      total: total,
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
                    '#${order['order_number'] ?? order['id']}',
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

class _DetailItemCard extends StatelessWidget {
  const _DetailItemCard({required this.item});

  final dynamic item;

  @override
  Widget build(BuildContext context) {
    final map = item is Map
        ? Map<String, dynamic>.from(item)
        : const <String, dynamic>{};
    final title = (map['product'] ?? map['name'] ?? '').toString();
    final desc = (map['description'] ?? '').toString();
    final qty = (map['quantity'] ?? 1).toString();
    final price = (map['price'] ?? '').toString();
    final image = (map['image'] ?? '').toString();
    return Container(
      decoration: BoxDecoration(
        color: StaticColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: StaticColors.cE2E2E2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: SizedBox(
              height: 120,
              child: image.isEmpty
                  ? const ColoredBox(color: StaticColors.white)
                  : Image.network(image, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.medium16(context),
                      ),
                    ),
                    Text(
                      '$price\$',
                      style: AppTextStyle.medium14(
                        context,
                        color: StaticColors.primary,
                      ),
                    ),
                  ],
                ),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyle.regular12(
                      context,
                      color: StaticColors.c9AA0A6,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${TranslationKeys.ordersAmount.tr(context: context)}: $qty',
                  style: AppTextStyle.regular16(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailSummaryPanel extends StatelessWidget {
  const _OrderDetailSummaryPanel({
    required this.notes,
    required this.customerType,
    required this.paymentType,
    required this.paymentStatus,
    required this.total,
  });

  final String notes;
  final String customerType;
  final String paymentType;
  final String paymentStatus;
  final String total;

  @override
  Widget build(BuildContext context) {
    Widget row(String l, String v, {Color? valueColor}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text('$l:', style: AppTextStyle.medium14(context))),
          Text(
            v,
            style: AppTextStyle.regular16(
              context,
              color: valueColor ?? StaticColors.c666666,
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
          TranslationKeys.ordersPaymentType.tr(context: context),
          paymentType,
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
