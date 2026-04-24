import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_orders_page_result.dart';

abstract class OrdersRepository {
  /// [nextPageUrl] — API `next` to'liq URL; `null` bo'lsa birinchi sahifa.
  Future<VendorOrdersPageResult> fetchOrders({String? nextPageUrl});

  Future<Map<String, dynamic>> fetchOrderDetail({required int orderId});

  Future<void> updateOrderStatus({
    required int orderId,
    required String status,
  });
}
