import 'package:equatable/equatable.dart';

class VendorWsOrderItemModifierModel extends Equatable {
  const VendorWsOrderItemModifierModel({
    required this.name,
    required this.groupName,
    required this.price,
  });

  final String name;
  final String groupName;
  final String price;

  factory VendorWsOrderItemModifierModel.fromJson(Map<String, dynamic> json) {
    return VendorWsOrderItemModifierModel(
      name: json['name']?.toString() ?? '',
      groupName:
          json['group_name']?.toString() ?? json['groupName']?.toString() ?? '',
      price: json['price']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    if (groupName.isNotEmpty) 'group_name': groupName,
    'price': price.isEmpty ? '0.00' : price,
  };

  @override
  List<Object?> get props => [name, groupName, price];
}

/// WebSocket `order_created` ichidagi bitta mahsulot qatori.
class VendorWsOrderItemModel extends Equatable {
  const VendorWsOrderItemModel({
    required this.product,
    required this.description,
    required this.quantity,
    required this.price,
    required this.originalPrice,
    required this.modifiers,
    required this.modifiersTotal,
    this.image,
    this.totalPrice,
  });

  final String product;
  final String description;
  final int quantity;
  final String price;
  final String originalPrice;
  final String? image;
  final String? totalPrice;
  final List<VendorWsOrderItemModifierModel> modifiers;
  final String modifiersTotal;

  /// Chek va boshqa joylar uchun alias.
  String get name => product;

  factory VendorWsOrderItemModel.fromJson(Map<String, dynamic> json) {
    final rawModifiers = json['modifiers'];
    final modifiers = <VendorWsOrderItemModifierModel>[];
    if (rawModifiers is List) {
      for (final entry in rawModifiers) {
        if (entry is Map) {
          modifiers.add(
            VendorWsOrderItemModifierModel.fromJson(
              Map<String, dynamic>.from(entry),
            ),
          );
        }
      }
    }

    final product = json['product']?.toString() ??
        json['name']?.toString() ??
        json['product_name']?.toString() ??
        json['title']?.toString() ??
        '';

    return VendorWsOrderItemModel(
      product: product,
      description: json['description']?.toString() ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ??
          int.tryParse(json['qty']?.toString() ?? '') ??
          1,
      price: json['price']?.toString() ?? json['unit_price']?.toString() ?? '',
      originalPrice: json['original_price']?.toString() ?? '',
      image: json['image']?.toString(),
      totalPrice: json['total_price']?.toString() ??
          json['line_total']?.toString(),
      modifiers: modifiers,
      modifiersTotal: json['modifiers_total']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'product': product,
    if (description.isNotEmpty) 'description': description,
    'quantity': quantity,
    if (price.isNotEmpty) 'price': price,
    if (originalPrice.isNotEmpty) 'original_price': originalPrice,
    if (image != null && image!.isNotEmpty) 'image': image,
    if (totalPrice != null && totalPrice!.isNotEmpty) 'total_price': totalPrice,
    if (modifiers.isNotEmpty)
      'modifiers': modifiers.map((e) => e.toJson()).toList(growable: false),
    if (modifiersTotal.isNotEmpty) 'modifiers_total': modifiersTotal,
  };

  @override
  List<Object?> get props => [
    product,
    description,
    quantity,
    price,
    originalPrice,
    image,
    totalPrice,
    modifiers,
    modifiersTotal,
  ];
}
