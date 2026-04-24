import 'package:flutter/material.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_ui_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/utils/order_id_search_match.dart';

mixin OrdersBodySectionMixin<T extends StatefulWidget> on State<T> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchController = TextEditingController();
  final ValueNotifier<bool> searchExpandedNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<int> localUiVersionNotifier = ValueNotifier<int>(0);

  void initOrdersBodySectionMixin({required VoidCallback onScroll}) {
    scrollController.addListener(onScroll);
    searchController.addListener(_notifyLocalUiChanged);
  }

  void disposeOrdersBodySectionMixin({required VoidCallback onScroll}) {
    scrollController.removeListener(onScroll);
    scrollController.dispose();
    searchController.removeListener(_notifyLocalUiChanged);
    searchController.dispose();
    searchExpandedNotifier.dispose();
    localUiVersionNotifier.dispose();
  }

  bool shouldLoadMore(OrdersState state) {
    if (!scrollController.hasClients) return false;
    final pos = scrollController.position;
    if (pos.pixels < pos.maxScrollExtent - 240) return false;
    if (!state.hasMore || state.isLoadingMore || state.status != OrdersLoadStatus.success) return false;
    return true;
  }

  List<VendorOrderUiModel> visibleOrders(List<VendorOrderUiModel> source) {
    final q = searchController.text;
    return [
      for (final o in source)
        if (orderIdMatchesSearch(o.id, q)) o,
    ];
  }

  void openSearch() => searchExpandedNotifier.value = true;

  void closeSearch() {
    searchController.clear();
    searchExpandedNotifier.value = false;
    _notifyLocalUiChanged();
  }

  void _notifyLocalUiChanged() {
    localUiVersionNotifier.value++;
  }
}
