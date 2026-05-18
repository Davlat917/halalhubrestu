import 'package:equatable/equatable.dart';

/// WebSocket `order_created` xabari (`customer_name` va boshqalar).
class VendorWsOrderCreatedPayload extends Equatable {
  const VendorWsOrderCreatedPayload({
    required this.type,
    this.orderId,
    this.orderNumber,
    this.customerName,
    this.orderType,
    this.createdAt,
  });

  final String type;
  final int? orderId;
  final String? orderNumber;
  final String? customerName;
  final String? orderType;
  final String? createdAt;

  factory VendorWsOrderCreatedPayload.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString().trim());
    }

    return VendorWsOrderCreatedPayload(
      type: json['type'] as String? ?? '',
      orderId: parseId(json['order_id'] ?? json['orderId'] ?? json['id']),
      orderNumber: (json['order_number'] ?? json['orderNumber'])?.toString(),
      customerName: json['customer_name'] as String?,
      orderType: (json['order_type'] ?? json['orderType'])?.toString(),
      createdAt: (json['created_at'] ?? json['createdAt'])?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type,
        if (orderId != null) 'order_id': orderId,
        if (orderNumber != null) 'order_number': orderNumber,
        if (customerName != null) 'customer_name': customerName,
        if (orderType != null) 'order_type': orderType,
        if (createdAt != null) 'created_at': createdAt,
      };

  @override
  List<Object?> get props => [
        type,
        orderId,
        orderNumber,
        customerName,
        orderType,
        createdAt,
      ];
}
