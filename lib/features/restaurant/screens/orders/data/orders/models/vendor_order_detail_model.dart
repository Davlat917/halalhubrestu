import 'package:equatable/equatable.dart';

class VendorOrderDetailModifierModel extends Equatable {
  const VendorOrderDetailModifierModel({
    required this.name,
    required this.groupName,
    required this.price,
  });

  final String name;
  final String groupName;
  final String price;

  factory VendorOrderDetailModifierModel.fromJson(Map<String, dynamic> json) {
    return VendorOrderDetailModifierModel(
      name: json['name']?.toString() ?? '',
      groupName:
          json['group_name']?.toString() ?? json['groupName']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [name, groupName, price];
}

class VendorOrderDetailItemModel extends Equatable {
  const VendorOrderDetailItemModel({
    required this.id,
    required this.productId,
    required this.product,
    required this.description,
    required this.category,
    required this.quantity,
    required this.image,
    required this.price,
    required this.modifiers,
    required this.modifiersTotal,
    required this.isUnavailable,
  });

  /// OrderItem id — `unavailable_item_ids` uchun.
  final int id;

  /// Mahsulot katalog id (reference).
  final int productId;
  final String product;
  final String description;
  final String category;
  final int quantity;
  final String image;
  final String price;
  final List<VendorOrderDetailModifierModel> modifiers;
  final String modifiersTotal;
  final bool isUnavailable;

  factory VendorOrderDetailItemModel.fromJson(Map<String, dynamic> json) {
    final rawModifiers = json['modifiers'];
    final modifiers = <VendorOrderDetailModifierModel>[];
    if (rawModifiers is List) {
      for (final entry in rawModifiers) {
        if (entry is Map) {
          modifiers.add(
            VendorOrderDetailModifierModel.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          );
        }
      }
    }

    final categoryRaw = json['category'];
    final category = categoryRaw is Map
        ? (categoryRaw['name']?.toString() ?? '')
        : (json['category']?.toString() ??
              json['category_name']?.toString() ??
              '');

    final rawId = json['id'] ??
        json['order_item_id'] ??
        json['item_id'] ??
        json['pk'] ??
        (json['order_item'] is Map ? json['order_item']['id'] : null);

    final rawProductId = json['product_id'] ?? json['productId'];

    return VendorOrderDetailItemModel(
      id: (rawId as num?)?.toInt() ?? int.tryParse(rawId?.toString() ?? '') ?? 0,
      productId: (rawProductId as num?)?.toInt() ??
          int.tryParse(rawProductId?.toString() ?? '') ??
          0,
      product: json['product']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      category: category,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      image: json['image']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
      modifiers: modifiers,
      modifiersTotal: json['modifiers_total']?.toString() ?? '',
      isUnavailable: json['is_unavailable'] == true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    product,
    description,
    category,
    quantity,
    image,
    price,
    modifiers,
    modifiersTotal,
    isUnavailable,
  ];
}

class VendorOrderDetailModel extends Equatable {
  const VendorOrderDetailModel({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.isScheduled,
    this.scheduledFor,
    required this.preparationNotified,
    required this.deliveryPhone,
    required this.deliveryAddress,
    this.deliveryLat,
    this.deliveryLng,
    required this.status,
    required this.paymentType,
    required this.orderType,
    required this.paymentStatus,
    required this.totalPrice,
    required this.itemsTotal,
    required this.comment,
    required this.items,
    required this.isRequestUtensils,
  });

  final int id;
  final String orderNumber;
  final String createdAt;
  final bool isScheduled;
  final String? scheduledFor;
  final bool preparationNotified;
  final String deliveryPhone;
  final String deliveryAddress;
  final double? deliveryLat;
  final double? deliveryLng;
  final String status;
  final String paymentType;
  final String orderType;
  final String paymentStatus;
  final String totalPrice;
  final String itemsTotal;
  final String comment;
  final List<VendorOrderDetailItemModel> items;
  final bool isRequestUtensils;

  String get displayOrderNumber =>
      orderNumber.isNotEmpty ? orderNumber : id.toString();

  bool get isPickup => orderType.toLowerCase() == 'pickup';

  bool get isDelivery => orderType.toLowerCase() == 'delivery';

  factory VendorOrderDetailModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <VendorOrderDetailItemModel>[];
    if (rawItems is List) {
      for (final entry in rawItems) {
        if (entry is Map) {
          items.add(
            VendorOrderDetailItemModel.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          );
        }
      }
    }

    return VendorOrderDetailModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderNumber: json['order_number']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      isScheduled: json['is_scheduled'] == true,
      scheduledFor: json['scheduled_for']?.toString(),
      preparationNotified: json['preparation_notified'] == true,
      deliveryPhone: json['delivery_phone']?.toString() ?? '',
      deliveryAddress: json['delivery_address']?.toString() ?? '',
      deliveryLat: (json['delivery_lat'] as num?)?.toDouble(),
      deliveryLng: (json['delivery_lng'] as num?)?.toDouble(),
      status: json['status']?.toString() ?? '',
      paymentType: json['payment_type']?.toString() ?? '',
      orderType: json['order_type']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      totalPrice: json['total_price']?.toString() ?? '',
      itemsTotal: json['items_total']?.toString() ?? '',
      comment: json['comment']?.toString() ?? '',
      items: items,
      isRequestUtensils: json['is_request_utensils'] == true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderNumber,
    createdAt,
    isScheduled,
    scheduledFor,
    preparationNotified,
    deliveryPhone,
    deliveryAddress,
    deliveryLat,
    deliveryLng,
    status,
    paymentType,
    orderType,
    paymentStatus,
    totalPrice,
    itemsTotal,
    comment,
    items,
    isRequestUtensils,
  ];
}
