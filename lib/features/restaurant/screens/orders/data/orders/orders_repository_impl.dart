import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart' show ExceptionHandler, NetworkException, UnexpectedException;
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_order_detail_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_orders_item.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_orders_page_result.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/orders_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: OrdersRepository)
class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._dio);

  final Dio _dio;

  Never _rethrow(Object e) {
    final ex = ExceptionHandler.handleException(e);
    if (ex is NetworkException) throw ex;
    if (ex is UnexpectedException) {
      throw NetworkException(message: ex.message);
    }
    throw NetworkException(message: ex.toString());
  }

  @override
  Future<VendorOrdersPageResult> fetchOrders({String? nextPageUrl}) async {
    try {
      final Response<dynamic> response;
      final next = nextPageUrl?.trim();
      if (next != null && next.isNotEmpty) {
        final uri = Uri.tryParse(next);
        if (uri != null && uri.hasScheme) {
          response = await _dio.getUri(uri);
        } else {
          response = await _dio.get(next);
        }
      } else {
        response = await _dio.get(Constants.vendorsOrders);
      }

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw NetworkException(message: TranslationKeys.ordersInvalidOrdersResponse.tr());
      }
      return VendorOrdersPageResult.fromJson(data);
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<VendorOrderDetailModel> fetchOrderDetail({required int orderId}) async {
    try {
      final response = await _dio.get(Constants.vendorsOrderDetailById(orderId));
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw NetworkException(message: TranslationKeys.ordersInvalidDetailResponse.tr());
      }
      return VendorOrderDetailModel.fromJson(data);
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<void> updateOrderStatus({required int orderId, required String status}) async {
    try {
      await _dio.patch(Constants.vendorsOrderStatusById(orderId), data: {'status': status});
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<VendorOrdersItem> submitOrderDecision({
    required int orderId,
    required String action,
    List<int> unavailableItemIds = const [],
  }) async {
    try {
      final response = await _dio.post(
        Constants.vendorsOrderDecisionById(orderId),
        data: {
          'action': action,
          'unavailable_item_ids': unavailableItemIds,
        },
      );
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw NetworkException(
          message: TranslationKeys.ordersInvalidOrdersResponse.tr(),
        );
      }
      return VendorOrdersItem.fromJson(data);
    } catch (e) {
      _rethrow(e);
    }
  }
}
