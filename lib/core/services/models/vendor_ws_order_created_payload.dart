import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/core/services/models/vendor_ws_order_item_model.dart';
import 'package:halalhub_restaurant/core/services/models/vendor_ws_price_data_model.dart';

/// WebSocket `order_created` xabari to'liq modeli.
///
/// Namuna:
/// ```json
/// {
///   "type": "order_created",
///   "order_id": 142,
///   "order_number": "ORD-BFD2B3FF",
///   "order_type": "delivery",
///   "payment_type": "card",
///   "customer_name": "Marakand Marakand",
///   "is_scheduled": false,
///   "scheduled_for": null,
///   "message": "New order received",
///   "items": [...],
///   "price_data": {...}
/// }
/// ```
class VendorWsOrderCreatedPayload extends Equatable {
  const VendorWsOrderCreatedPayload({
    required this.type,
    this.orderId,
    this.orderNumber,
    this.customerName,
    this.orderType,
    this.paymentType,
    this.paymentStatus,
    this.createdAt,
    this.message,
    this.comment,
    this.deliveryPhone,
    this.deliveryAddress,
    this.itemsTotal,
    this.totalPrice,
    this.isScheduled = false,
    this.scheduledFor,
    this.isRequestUtensils = false,
    this.items = const [],
    this.priceData,
  });

  final String type;
  final int? orderId;
  final String? orderNumber;
  final String? customerName;
  final String? orderType;
  final String? paymentType;
  final String? paymentStatus;
  final String? createdAt;
  final String? message;
  final String? comment;
  final String? deliveryPhone;
  final String? deliveryAddress;
  final String? itemsTotal;
  final String? totalPrice;
  final bool isScheduled;
  final String? scheduledFor;
  final bool isRequestUtensils;
  final List<VendorWsOrderItemModel> items;
  final VendorWsPriceDataModel? priceData;

  bool get isDelivery {
    final normalized = (orderType ?? '').trim().toLowerCase();
    return normalized == 'delivery' ||
        normalized == 'driver' ||
        normalized == 'courier';
  }

  bool get isPickup => !isDelivery;

  String? get effectiveTotalPrice =>
      totalPrice ?? priceData?.totalPrice ?? priceData?.originalTotalPrice;

  String? get effectiveSubtotal =>
      priceData?.subtotal ?? itemsTotal;

  bool get hasRichReceiptData =>
      items.isNotEmpty && priceData != null && !priceData!.isEmpty;

  factory VendorWsOrderCreatedPayload.fromJson(Map<String, dynamic> json) {
    int? parseId(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString().trim());
    }

    String? readString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return null;
    }

    final rawItems = json['items'];
    final items = <VendorWsOrderItemModel>[];
    if (rawItems is List) {
      for (final entry in rawItems) {
        if (entry is Map) {
          items.add(
            VendorWsOrderItemModel.fromJson(Map<String, dynamic>.from(entry)),
          );
        }
      }
    }

    VendorWsPriceDataModel? priceData;
    final rawPriceData = json['price_data'];
    if (rawPriceData is Map) {
      priceData = VendorWsPriceDataModel.fromJson(
        Map<String, dynamic>.from(rawPriceData),
      );
      if (priceData.isEmpty) priceData = null;
    }

    final rootTotal = readString(const ['total_price', 'total']);
    final rootItemsTotal = readString(const ['items_total', 'itemsTotal']);

    return VendorWsOrderCreatedPayload(
      type: json['type']?.toString() ?? '',
      orderId: parseId(json['order_id'] ?? json['orderId'] ?? json['id']),
      orderNumber: readString(const ['order_number', 'orderNumber', 'number']),
      customerName: readString(const [
        'customer_name',
        'customer_full_name',
        'full_name',
        'client_name',
        'buyer_name',
      ]),
      orderType: readString(const ['order_type', 'orderType']),
      paymentType: readString(const ['payment_type', 'paymentType']),
      paymentStatus: readString(const ['payment_status', 'paymentStatus']),
      createdAt: readString(const ['created_at', 'createdAt', 'placed_at']),
      message: readString(const ['message', 'title', 'body']),
      comment: readString(const ['comment', 'notes', 'special_notes']),
      deliveryPhone: readString(const [
        'delivery_phone',
        'deliveryPhone',
        'phone',
      ]),
      deliveryAddress: readString(const [
        'delivery_address',
        'deliveryAddress',
        'address',
      ]),
      itemsTotal: rootItemsTotal ?? priceData?.subtotal,
      totalPrice: rootTotal ?? priceData?.totalPrice,
      isScheduled: json['is_scheduled'] == true,
      scheduledFor: readString(const ['scheduled_for', 'scheduledFor']),
      isRequestUtensils: json['is_request_utensils'] == true,
      items: items,
      priceData: priceData,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    if (orderId != null) 'order_id': orderId,
    if (orderNumber != null) 'order_number': orderNumber,
    if (customerName != null) 'customer_name': customerName,
    if (orderType != null) 'order_type': orderType,
    if (paymentType != null) 'payment_type': paymentType,
    if (paymentStatus != null) 'payment_status': paymentStatus,
    if (createdAt != null) 'created_at': createdAt,
    if (message != null) 'message': message,
    if (comment != null) 'comment': comment,
    if (deliveryPhone != null) 'delivery_phone': deliveryPhone,
    if (deliveryAddress != null) 'delivery_address': deliveryAddress,
    if (itemsTotal != null) 'items_total': itemsTotal,
    if (totalPrice != null) 'total_price': totalPrice,
    'is_scheduled': isScheduled,
    if (scheduledFor != null) 'scheduled_for': scheduledFor,
    if (isRequestUtensils) 'is_request_utensils': isRequestUtensils,
    if (items.isNotEmpty)
      'items': items.map((e) => e.toJson()).toList(growable: false),
    if (priceData != null) 'price_data': priceData!.toJson(),
  };

  @override
  List<Object?> get props => [
    type,
    orderId,
    orderNumber,
    customerName,
    orderType,
    paymentType,
    paymentStatus,
    createdAt,
    message,
    comment,
    deliveryPhone,
    deliveryAddress,
    itemsTotal,
    totalPrice,
    isScheduled,
    scheduledFor,
    isRequestUtensils,
    items,
    priceData,
  ];
}
