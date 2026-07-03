import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_order_detail_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/orders_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_ui_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/screens/order_history/bloc/order_history_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/screens/order_history/bloc/order_history_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/screens/order_history/bloc/order_history_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/utils/order_id_search_match.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/widgets/order_detail_sheet.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/widgets/orders_list_header.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/widgets/orders_empty_view.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/widgets/vendor_order_card.dart';

class OrderHistoryBodySection extends StatefulWidget {
  const OrderHistoryBodySection({
    super.key,
    this.maxContentWidth,
    this.columnCount = 1,
  });

  final double? maxContentWidth;
  final int columnCount;

  @override
  State<OrderHistoryBodySection> createState() =>
      _OrderHistoryBodySectionState();
}

class _OrderHistoryBodySectionState extends State<OrderHistoryBodySection> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  bool _searchExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 240) return;
    final bloc = context.read<OrderHistoryBloc>();
    final s = bloc.state;
    if (!s.hasMore ||
        s.isLoadingMore ||
        s.status != OrderHistoryLoadStatus.success) {
      return;
    }
    bloc.add(const OrderHistoryLoadMoreRequested());
  }

  List<VendorOrderUiModel> _visibleItems(List<VendorOrderUiModel> items) {
    return [
      for (final o in items)
        if (orderIdMatchesSearch(o.id, _searchController.text)) o,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPad = widget.columnCount > 1 ? 20.0 : 12.0;
    final header = OrdersListHeader(
      horizontalPadding: horizontalPad,
      title: TranslationKeys.ordersHistoryTitle,
      onOrderHistoryTap: null,
      searchController: _searchController,
      searchExpanded: _searchExpanded,
      onSearchOpen: () => setState(() => _searchExpanded = true),
      onSearchClose: () => setState(() => _searchExpanded = false),
      onSearchQueryChanged: () => setState(() {}),
    );

    Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: BlocBuilder<OrderHistoryBloc, OrderHistoryState>(
            builder: (context, state) {
              if (state.status == OrderHistoryLoadStatus.loading &&
                  state.items.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              if (state.status == OrderHistoryLoadStatus.failure &&
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
                          onPressed: () => context.read<OrderHistoryBloc>().add(
                            const OrderHistoryLoadRequested(),
                          ),
                          child: Text(
                            TranslationKeys.retry.tr(context: context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              if (state.items.isEmpty) return const OrdersEmptyView();

              final visible = _visibleItems(state.items);
              if (visible.isEmpty &&
                  state.status == OrderHistoryLoadStatus.success) {
                return RefreshIndicator(
                  color: StaticColors.primary,
                  onRefresh: () async {
                    final bloc = context.read<OrderHistoryBloc>();
                    bloc.add(const OrderHistoryRefreshRequested());
                    await bloc.stream.firstWhere(
                      (s) => s.status != OrderHistoryLoadStatus.loading,
                    );
                  },
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      horizontalPad,
                      24,
                      horizontalPad,
                      24,
                    ),
                    children: [
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.15,
                      ),
                      Center(
                        child: Text(
                          TranslationKeys.ordersNotFoundById.tr(
                            context: context,
                          ),
                          textAlign: TextAlign.center,
                          style: AppTextStyle.regular16(
                            context,
                            color: StaticColors.c666666,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              final Widget list;
              if (widget.columnCount <= 1) {
                list = ListView.separated(
                  controller: _scrollController,
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
                    return _historyCard(context, visible[index]);
                  },
                );
              } else {
                final gridDataRows = (visible.length / widget.columnCount)
                    .ceil();
                final gridItemCount =
                    gridDataRows + (state.isLoadingMore ? 1 : 0);
                list = ListView.builder(
                  controller: _scrollController,
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
                    final i0 = row * widget.columnCount;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var c = 0; c < widget.columnCount; c++) ...[
                            if (c > 0) const SizedBox(width: 12),
                            Expanded(
                              child: i0 + c < visible.length
                                  ? _historyCard(context, visible[i0 + c])
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
                  final bloc = context.read<OrderHistoryBloc>();
                  bloc.add(const OrderHistoryRefreshRequested());
                  await bloc.stream.firstWhere(
                    (s) => s.status != OrderHistoryLoadStatus.loading,
                  );
                },
                child: list,
              );
            },
          ),
        ),
      ],
    );

    if (widget.maxContentWidth != null) {
      column = Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: widget.maxContentWidth!),
          child: column,
        ),
      );
    }

    return ColoredBox(color: StaticColors.cF8F8F8, child: column);
  }

  Widget _historyCard(BuildContext context, VendorOrderUiModel order) {
    return VendorOrderCard(
      order: order,
      onMore: () => _openOrderDetail(context, order),
    );
  }

  Future<void> _openOrderDetail(
    BuildContext context,
    VendorOrderUiModel order,
  ) async {
    final repo = getIt<OrdersRepository>();
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
      detail = await repo.fetchOrderDetail(orderId: order.backendId);
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
          child: OrderDetailSheet(order: detail!, expandBody: false),
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
            OrderDetailSheet(order: detail!, scrollController: controller),
      ),
    );
  }
}

NavigatorState _navigatorOf(BuildContext context) =>
    Navigator.of(context, rootNavigator: true);
