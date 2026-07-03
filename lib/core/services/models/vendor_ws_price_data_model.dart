import 'package:equatable/equatable.dart';

/// WebSocket `order_created` ichidagi `price_data` bloki.
class VendorWsPriceDataModel extends Equatable {
  const VendorWsPriceDataModel({
    this.subtotal,
    this.itemsTotal,
    this.promotion,
    this.discount,
    this.serviceFee,
    this.commissionFee,
    this.deliveryPrice,
    this.deliveryFee,
    this.deliveryDistanceMiles,
    this.deliveryAvailable,
    this.pickupAvailable,
    this.deliveryUnavailableReason,
    this.tax,
    this.taxRate,
    this.taxState,
    this.tip,
    this.originalTotalPrice,
    this.totalPrice,
  });

  final String? subtotal;
  final String? itemsTotal;
  final String? promotion;
  final String? discount;
  final String? serviceFee;
  final String? commissionFee;
  final String? deliveryPrice;
  final String? deliveryFee;
  final String? deliveryDistanceMiles;
  final bool? deliveryAvailable;
  final bool? pickupAvailable;
  final String? deliveryUnavailableReason;
  final String? tax;
  final String? taxRate;
  final String? taxState;
  final String? tip;
  final String? originalTotalPrice;
  final String? totalPrice;

  factory VendorWsPriceDataModel.fromJson(Map<String, dynamic> json) {
    String? readString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return null;
    }

    bool? readBool(String key) {
      final value = json[key];
      if (value is bool) return value;
      if (value == null) return null;
      final normalized = value.toString().trim().toLowerCase();
      if (normalized == 'true') return true;
      if (normalized == 'false') return false;
      return null;
    }

    return VendorWsPriceDataModel(
      subtotal: readString(const ['subtotal', 'item_total_price', 'items_total_price']),
      itemsTotal: readString(const ['items_total']),
      promotion: readString(const ['promotion']),
      discount: readString(const ['discount']),
      serviceFee: readString(const ['service_fee']),
      commissionFee: readString(const ['commission_fee']),
      deliveryPrice: readString(const ['delivery_price']),
      deliveryFee: readString(const ['delivery_fee']),
      deliveryDistanceMiles: readString(const ['delivery_distance_miles']),
      deliveryAvailable: readBool('delivery_available'),
      pickupAvailable: readBool('pickup_available'),
      deliveryUnavailableReason:
          readString(const ['delivery_unavailable_reason']),
      tax: readString(const ['tax']),
      taxRate: readString(const ['tax_rate']),
      taxState: readString(const ['tax_state']),
      tip: readString(const ['tip']),
      originalTotalPrice: readString(const ['original_total_price']),
      totalPrice: readString(const ['total_price', 'total']),
    );
  }

  Map<String, dynamic> toJson() => {
    if (subtotal != null) 'subtotal': subtotal,
    if (itemsTotal != null) 'items_total': itemsTotal,
    if (promotion != null) 'promotion': promotion,
    if (discount != null) 'discount': discount,
    if (serviceFee != null) 'service_fee': serviceFee,
    if (commissionFee != null) 'commission_fee': commissionFee,
    if (deliveryPrice != null) 'delivery_price': deliveryPrice,
    if (deliveryFee != null) 'delivery_fee': deliveryFee,
    if (deliveryDistanceMiles != null)
      'delivery_distance_miles': deliveryDistanceMiles,
    if (deliveryAvailable != null) 'delivery_available': deliveryAvailable,
    if (pickupAvailable != null) 'pickup_available': pickupAvailable,
    if (deliveryUnavailableReason != null)
      'delivery_unavailable_reason': deliveryUnavailableReason,
    if (tax != null) 'tax': tax,
    if (taxRate != null) 'tax_rate': taxRate,
    if (taxState != null) 'tax_state': taxState,
    if (tip != null) 'tip': tip,
    if (originalTotalPrice != null) 'original_total_price': originalTotalPrice,
    if (totalPrice != null) 'total_price': totalPrice,
  };

  bool get isEmpty =>
      subtotal == null &&
      itemsTotal == null &&
      promotion == null &&
      discount == null &&
      serviceFee == null &&
      commissionFee == null &&
      deliveryPrice == null &&
      deliveryFee == null &&
      deliveryDistanceMiles == null &&
      deliveryAvailable == null &&
      pickupAvailable == null &&
      deliveryUnavailableReason == null &&
      tax == null &&
      taxRate == null &&
      taxState == null &&
      tip == null &&
      originalTotalPrice == null &&
      totalPrice == null;

  @override
  List<Object?> get props => [
    subtotal,
    itemsTotal,
    promotion,
    discount,
    serviceFee,
    commissionFee,
    deliveryPrice,
    deliveryFee,
    deliveryDistanceMiles,
    deliveryAvailable,
    pickupAvailable,
    deliveryUnavailableReason,
    tax,
    taxRate,
    taxState,
    tip,
    originalTotalPrice,
    totalPrice,
  ];
}
