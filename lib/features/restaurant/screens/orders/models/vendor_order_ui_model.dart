import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_status.dart';

/// UI uchun namuna buyurtma (keyin API modeliga almashtiriladi).
class VendorOrderUiModel {
  const VendorOrderUiModel({
    required this.backendId,
    required this.id,
    required this.createdAtLabel,
    required this.status,
    required this.itemsSummary,
    required this.totalLabel,
    this.orderType,
  });

  final int backendId;
  final String id;
  final String createdAtLabel;
  final VendorOrderStatus status;
  final String itemsSummary;
  final String totalLabel;
  final String? orderType;

  bool get isPickup => orderType?.toLowerCase() == 'pickup';

  VendorOrderUiModel copyWith({
    int? backendId,
    String? id,
    String? createdAtLabel,
    VendorOrderStatus? status,
    String? itemsSummary,
    String? totalLabel,
    String? orderType,
  }) {
    return VendorOrderUiModel(
      backendId: backendId ?? this.backendId,
      id: id ?? this.id,
      createdAtLabel: createdAtLabel ?? this.createdAtLabel,
      status: status ?? this.status,
      itemsSummary: itemsSummary ?? this.itemsSummary,
      totalLabel: totalLabel ?? this.totalLabel,
      orderType: orderType ?? this.orderType,
    );
  }

  bool get isTerminal =>
      status == VendorOrderStatus.completed ||
      status == VendorOrderStatus.delivered ||
      status == VendorOrderStatus.canceled ||
      status == VendorOrderStatus.deliveryFailed;

  /// 1–3: chapdan o‘ngga faol tugunlar soni.
  int get progressNodesActive {
    switch (status) {
      case VendorOrderStatus.newOrder:
        return 1;
      case VendorOrderStatus.accepted:
        return 2;
      case VendorOrderStatus.ready:
        return 3;
      case VendorOrderStatus.completed:
      case VendorOrderStatus.delivered:
        return 3;
      case VendorOrderStatus.canceled:
      case VendorOrderStatus.deliveryFailed:
        return 0;
    }
  }
}
