import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_status.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_ui_model.dart';

class VendorOrderHistoryItem extends Equatable {
  const VendorOrderHistoryItem({
    required this.id,
    required this.orderNumber,
    required this.formattedDate,
    required this.itemsSummary,
    required this.totalPrice,
    required this.status,
    this.statusDisplay,
  });

  final int id;
  final String orderNumber;
  final String formattedDate;
  final String itemsSummary;
  final String totalPrice;
  final String status;
  final String? statusDisplay;

  factory VendorOrderHistoryItem.fromJson(Map<String, dynamic> json) {
    return VendorOrderHistoryItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      formattedDate: json['formatted_date'] as String? ?? '',
      itemsSummary: json['items_summary'] as String? ?? '',
      totalPrice: json['total_price']?.toString() ?? '',
      status: json['status'] as String? ?? '',
      statusDisplay: json['status_display'] as String?,
    );
  }

  VendorOrderUiModel toUiModel() {
    return VendorOrderUiModel(
      backendId: id,
      id: orderNumber,
      createdAtLabel: formattedDate,
      status: _statusFromApi(status),
      itemsSummary: itemsSummary,
      totalLabel: '$totalPrice\$',
    );
  }

  static VendorOrderStatus _statusFromApi(String raw) {
    switch (raw.toLowerCase()) {
      case 'completed':
        return VendorOrderStatus.completed;
      case 'delivered':
        return VendorOrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return VendorOrderStatus.canceled;
      case 'delivery_failed':
        return VendorOrderStatus.deliveryFailed;
      default:
        return VendorOrderStatus.completed;
    }
  }

  @override
  List<Object?> get props => [id, orderNumber, formattedDate, itemsSummary, totalPrice, status, statusDisplay];
}
