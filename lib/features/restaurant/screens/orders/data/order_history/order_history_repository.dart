import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/order_history/models/vendor_order_history_page_result.dart';

abstract class OrderHistoryRepository {
  /// [nextPageUrl] — API `next` to‘liq URL; `null` bo‘lsa birinchi sahifa.
  Future<VendorOrderHistoryPageResult> fetchOrderHistory({String? nextPageUrl});
}
