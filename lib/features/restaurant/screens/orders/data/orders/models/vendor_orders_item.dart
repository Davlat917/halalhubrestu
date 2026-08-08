import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_status.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_ui_model.dart';

class VendorOrdersItem extends Equatable {
  const VendorOrdersItem({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.itemsSummary,
    required this.totalPrice,
    required this.status,
    required this.orderType,
    this.formattedDate,
    this.statusDisplay,
  });

  final int id;
  final String orderNumber;
  final String createdAt;
  final String itemsSummary;
  final String totalPrice;
  final String status;
  final String orderType;
  final String? formattedDate;
  final String? statusDisplay;

  factory VendorOrdersItem.fromJson(Map<String, dynamic> json) {
    return VendorOrdersItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      itemsSummary: json['orders'] as String? ?? '',
      totalPrice: json['total_price']?.toString() ?? '',
      status: json['status'] as String? ?? '',
      orderType: json['order_type'] as String? ?? '',
      formattedDate: json['formatted_date'] as String?,
      statusDisplay: json['status_display'] as String?,
    );
  }

  VendorOrderUiModel toUiModel() {
    return VendorOrderUiModel(
      backendId: id,
      id: orderNumber,
      createdAtLabel: _formatDateLabel(),
      status: statusFromApi(status),
      itemsSummary: itemsSummary,
      totalLabel: '$totalPrice\$',
      orderType: orderType,
    );
  }

  String _formatDateLabel() {
    if (formattedDate != null && formattedDate!.trim().isNotEmpty) {
      return formattedDate!.trim();
    }
    final raw = createdAt.trim();
    if (raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt != null) {
      String two(int v) => v.toString().padLeft(2, '0');
      final d = two(dt.day);
      final m = two(dt.month);
      final y = dt.year;
      final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
      final minute = two(dt.minute);
      final suffix = dt.hour >= 12 ? 'PM' : 'AM';
      return '$d.$m.$y - ${two(hour12)}:$minute $suffix';
    }
    return raw;
  }

  /// API `status` qatorini UI enumiga aylantiradi (WS ovoz sinxroni ham shu bilan mos).
  static VendorOrderStatus statusFromApi(String raw) {
    switch (raw.toLowerCase()) {
      case 'pending':
      case 'created':
        return VendorOrderStatus.newOrder;
      case 'awaiting_customer':
        return VendorOrderStatus.awaitingCustomer;
      case 'confirmed':
      case 'preparing':
        return VendorOrderStatus.accepted;
      case 'ready':
      case 'assigned':
      case 'picked_up':
      case 'on_the_way':
        return VendorOrderStatus.ready;
      case 'cancelled':
      case 'canceled':
        return VendorOrderStatus.canceled;
      case 'delivery_failed':
        return VendorOrderStatus.deliveryFailed;
      case 'delivered':
        return VendorOrderStatus.delivered;
      case 'completed':
        return VendorOrderStatus.completed;
      default:
        return VendorOrderStatus.newOrder;
    }
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    createdAt,
    itemsSummary,
    totalPrice,
    status,
    formattedDate,
    statusDisplay,
    orderType,
  ];
}
