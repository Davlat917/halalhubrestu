import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_order_detail_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_orders_item.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_orders_page_result.dart';

abstract class OrdersRepository {
  /// [nextPageUrl] — API `next` to'liq URL; `null` bo'lsa birinchi sahifa.
  Future<VendorOrdersPageResult> fetchOrders({String? nextPageUrl});

  Future<VendorOrderDetailModel> fetchOrderDetail({required int orderId});

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  });

  /// Vendor decision: confirm / cancel (+ optional unavailable item ids).
  /// Returns the updated order from the API (status is authoritative).
  Future<VendorOrdersItem> submitOrderDecision({
    required int orderId,
    required String action,
    List<int> unavailableItemIds = const [],
  });
}
