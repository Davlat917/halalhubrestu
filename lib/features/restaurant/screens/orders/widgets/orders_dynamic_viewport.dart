import 'package:flutter/foundation.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_order_detail_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/orders_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_ui_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_status.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/widgets/order_detail_sheet.dart';
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
              prev.errorMessage != curr.errorMessage ||
              prev.listBannerOrderId != curr.listBannerOrderId ||
              prev.decisionLoadingOrderId != curr.decisionLoadingOrderId,
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: RefreshIndicator(
                    color: StaticColors.primary,
                    onRefresh: () async {
                      final bloc = context.read<OrdersBloc>();
                      bloc.add(const OrdersRefreshRequested());
                      await bloc.stream.firstWhere(
                        (s) => s.status != OrdersLoadStatus.loading,
                      );
                    },
                    child: list,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _card(BuildContext context, VendorOrderUiModel order) {
    final bloc = context.read<OrdersBloc>();
    return VendorOrderCard(
      order: order,
      onConfirm: () => bloc.add(
        OrdersDecisionRequested(
          orderBackendId: order.backendId,
          action: 'confirm',
        ),
      ),
      onCancel: () => bloc.add(
        OrdersDecisionRequested(
          orderBackendId: order.backendId,
          action: 'cancel',
        ),
      ),
      onReady: () => onStatusChangeRequest(order, 'ready'),
      onCompleted: () {
        final statusForDone = order.isPickup ? 'completed' : 'delivered';
        onStatusChangeRequest(order, statusForDone);
      },
      onMore: () => _openOrderDetail(context, order),
      onAwaitingExpired: () => bloc.add(
        OrdersAwaitingExpiredRequested(orderBackendId: order.backendId),
      ),
      onDismissCustomerBanner: () => bloc.add(
        OrdersCustomerBannerDismissed(orderBackendId: order.backendId),
      ),
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
    VendorOrderDetailModel? detail;
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

    final isNewOrder = order.status == VendorOrderStatus.newOrder;
    final isMobile = ResponsiveSection.isMobileLayout(context);
    final ordersBloc = context.read<OrdersBloc>();

    Future<void> onAccept(List<int> unavailableIds) async {
      final loadedDetail = detail;
      if (loadedDetail == null) return;
      // Never allow a "partial" accept without real OrderItem ids — empty list
      // means full confirm on the backend.
      final markedUnavailable = loadedDetail.items
          .where((item) => unavailableIds.contains(item.id))
          .length;
      if (unavailableIds.isNotEmpty &&
          (unavailableIds.any((id) => id <= 0) ||
              markedUnavailable != unavailableIds.length)) {
        getIt<Display>().error(
          TranslationKeys.ordersItemIdsMissing.tr(context: context),
        );
        return;
      }
      ordersBloc.add(
        OrdersDecisionRequested(
          orderBackendId: order.backendId,
          action: 'confirm',
          unavailableItemIds: unavailableIds,
        ),
      );
      if (context.mounted) Navigator.of(context).maybePop();
    }

    if (!isMobile) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => BlocProvider.value(
          value: ordersBloc,
          child: Dialog(
            backgroundColor: StaticColors.white,
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, state) {
                return OrderDetailSheet(
                  order: detail!,
                  expandBody: false,
                  acceptLoading:
                      state.decisionLoadingOrderId == order.backendId,
                  onAccept: isNewOrder ? onAccept : null,
                );
              },
            ),
          ),
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
      builder: (sheetContext) => BlocProvider.value(
        value: ordersBloc,
        child: DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.86,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) => BlocBuilder<OrdersBloc, OrdersState>(
            builder: (context, state) {
              return OrderDetailSheet(
                order: detail!,
                scrollController: controller,
                acceptLoading: state.decisionLoadingOrderId == order.backendId,
                onAccept: isNewOrder ? onAccept : null,
              );
            },
          ),
        ),
      ),
    );
  }
}

NavigatorState _navigatorOf(BuildContext context) =>
    Navigator.of(context, rootNavigator: true);
