import 'package:equatable/equatable.dart';

class VendorFinanceTransactionLineItemModel extends Equatable {
  const VendorFinanceTransactionLineItemModel({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.lineTotal,
    this.image,
  });

  final String productName;
  final int quantity;
  final String price;
  final double lineTotal;
  final String? image;

  factory VendorFinanceTransactionLineItemModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return VendorFinanceTransactionLineItemModel(
      productName: json['product_name']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: json['price']?.toString() ?? '',
      lineTotal: (json['line_total'] as num?)?.toDouble() ?? 0,
      image: json['image']?.toString(),
    );
  }

  @override
  List<Object?> get props => [productName, quantity, price, lineTotal, image];
}

class VendorFinanceTransactionItemModel extends Equatable {
  const VendorFinanceTransactionItemModel({
    required this.id,
    required this.orderNumber,
    required this.createdAt,
    required this.formattedDate,
    required this.customerName,
    required this.paymentType,
    required this.orderType,
    required this.status,
    required this.statusDisplay,
    required this.itemsTotal,
    required this.deliveryPrice,
    required this.serviceFee,
    required this.tax,
    required this.tip,
    required this.totalPrice,
    required this.itemsSummary,
    required this.items,
  });

  final int id;
  final String orderNumber;
  final String createdAt;
  final String formattedDate;
  final String customerName;
  final String paymentType;
  final String orderType;
  final String status;
  final String statusDisplay;
  final String itemsTotal;
  final String deliveryPrice;
  final String serviceFee;
  final String tax;
  final String tip;
  final String totalPrice;
  final String itemsSummary;
  final List<VendorFinanceTransactionLineItemModel> items;

  factory VendorFinanceTransactionItemModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <VendorFinanceTransactionLineItemModel>[];
    if (rawItems is List) {
      for (final e in rawItems) {
        if (e is Map) {
          items.add(
            VendorFinanceTransactionLineItemModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          );
        }
      }
    }

    return VendorFinanceTransactionItemModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderNumber: json['order_number']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      formattedDate: json['formatted_date']?.toString() ?? '',
      customerName: json['customer_name']?.toString() ?? '',
      paymentType: json['payment_type']?.toString() ?? '',
      orderType: json['order_type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusDisplay: json['status_display']?.toString() ?? '',
      itemsTotal: json['items_total']?.toString() ?? '',
      deliveryPrice: json['delivery_price']?.toString() ?? '',
      serviceFee: json['service_fee']?.toString() ?? '',
      tax: json['tax']?.toString() ?? '',
      tip: json['tip']?.toString() ?? '',
      totalPrice: json['total_price']?.toString() ?? '',
      itemsSummary: json['items_summary']?.toString() ?? '',
      items: items,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        createdAt,
        formattedDate,
        customerName,
        paymentType,
        orderType,
        status,
        statusDisplay,
        itemsTotal,
        deliveryPrice,
        serviceFee,
        tax,
        tip,
        totalPrice,
        itemsSummary,
        items,
      ];
}
