import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/orders_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/mixins/orders_body_section_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/widgets/orders_dynamic_viewport.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/widgets/orders_list_header.dart';

class OrdersBodySection extends StatefulWidget {
  const OrdersBodySection({super.key, this.maxContentWidth, this.columnCount = 1, this.onOrderHistoryTap});

  final double? maxContentWidth;
  final int columnCount;
  final VoidCallback? onOrderHistoryTap;

  @override
  State<OrdersBodySection> createState() => _OrdersBodySectionState();
}

class _OrdersBodySectionState extends State<OrdersBodySection> with OrdersBodySectionMixin<OrdersBodySection> {
  @override
  void initState() {
    super.initState();
    initOrdersBodySectionMixin(onScroll: _onScroll);
  }

  @override
  void dispose() {
    disposeOrdersBodySectionMixin(onScroll: _onScroll);
    super.dispose();
  }

  void _onScroll() {
    final bloc = context.read<OrdersBloc>();
    if (!shouldLoadMore(bloc.state)) return;
    bloc.add(const OrdersLoadMoreRequested());
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPad = widget.columnCount > 1 ? 20.0 : 12.0;

    final header = ValueListenableBuilder<bool>(
      valueListenable: searchExpandedNotifier,
      builder: (context, expanded, _) {
        return OrdersListHeader(
          horizontalPadding: horizontalPad,
          onOrderHistoryTap: widget.onOrderHistoryTap,
          searchController: searchController,
          searchExpanded: expanded,
          onSearchOpen: openSearch,
          onSearchClose: closeSearch,
          onSearchQueryChanged: () {},
        );
      },
    );

    Widget column = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Expanded(
          child: OrdersDynamicViewport(
            horizontalPad: horizontalPad,
            columnCount: widget.columnCount,
            localUiVersionNotifier: localUiVersionNotifier,
            scrollController: scrollController,
            searchController: searchController,
            visibleOrders: visibleOrders,
            ordersRepository: getIt<OrdersRepository>(),
            onStatusChangeRequest: (order, nextStatus) {
              context.read<OrdersBloc>().add(
                OrdersStatusUpdateRequested(orderBackendId: order.backendId, nextStatusApi: nextStatus),
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
}
