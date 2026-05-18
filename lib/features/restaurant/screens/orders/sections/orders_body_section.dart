import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/orders_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/mixins/orders_body_section_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/widgets/orders_dynamic_viewport.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/widgets/orders_list_header.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/services/receipt_printer_service.dart';

class OrdersBodySection extends StatefulWidget {
  const OrdersBodySection({super.key, this.maxContentWidth, this.columnCount = 1, this.onOrderHistoryTap});

  final double? maxContentWidth;
  final int columnCount;
  final VoidCallback? onOrderHistoryTap;

  @override
  State<OrdersBodySection> createState() => _OrdersBodySectionState();
}

class _OrdersBodySectionState extends State<OrdersBodySection> with OrdersBodySectionMixin<OrdersBodySection> {
  bool _printingSampleReceipt = false;

  Future<void> _onTestReceiptPrint() async {
    final service = getIt<ReceiptPrinterService>();
    final host = service.savedHost?.trim();
    if (host == null || host.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            TranslationKeys.printerConnectOrEnterIpFirst.tr(context: context),
          ),
        ),
      );
      return;
    }
    setState(() => _printingSampleReceipt = true);
    final ok = await service.printSampleOrderReceipt();
    if (!mounted) return;
    setState(() => _printingSampleReceipt = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? TranslationKeys.printerTestSent.tr(context: context)
              : TranslationKeys.printerSendFailed.tr(
                  context: context,
                  namedArgs: {
                    'port': '${ReceiptPrinterService.defaultRawPort}',
                  },
                ),
        ),
      ),
    );
  }

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
          onSearchQueryChanged: () {}, //
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
                OrdersStatusUpdateRequested(orderBackendId: order.backendId, nextStatusApi: nextStatus), //
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

    return Stack(
      children: [
        ColoredBox(color: StaticColors.cF8F8F8, child: column),
        Positioned(
          right: horizontalPad,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'orders_test_receipt_fab',
            onPressed: _printingSampleReceipt ? null : _onTestReceiptPrint,
            backgroundColor: StaticColors.primary,
            icon: _printingSampleReceipt
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: StaticColors.white,
                    ),
                  )
                : const Icon(Icons.receipt_long, color: StaticColors.white),
            label: Text(
              _printingSampleReceipt ? '...' : 'Test chek',
              style: const TextStyle(color: StaticColors.white),
            ),
          ),
        ),
      ],
    );
  }
}
