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
    this.awaitingStartedAt,
    this.isCustomerContinued = false,
    this.showCustomerContinuedBanner = false,
  });

  static const Duration awaitingCustomerTimeout = Duration(minutes: 3);

  final int backendId;
  final String id;
  final String createdAtLabel;
  final VendorOrderStatus status;
  final String itemsSummary;
  final String totalLabel;
  final String? orderType;
  final DateTime? awaitingStartedAt;

  /// Green header/border after customer continue (survives banner dismiss).
  final bool isCustomerContinued;

  /// Dismissible light-green info banner above the card.
  final bool showCustomerContinuedBanner;

  bool get isPickup => orderType?.toLowerCase() == 'pickup';

  Duration? get awaitingRemaining {
    final started = awaitingStartedAt;
    if (started == null || status != VendorOrderStatus.awaitingCustomer) {
      return null;
    }
    final end = started.add(awaitingCustomerTimeout);
    final left = end.difference(DateTime.now());
    return left.isNegative ? Duration.zero : left;
  }

  String get awaitingRemainingLabel {
    final left = awaitingRemaining ?? Duration.zero;
    final totalSeconds = left.inSeconds;
    final m = (totalSeconds ~/ 60).toString();
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  bool get isAwaitingExpired {
    final left = awaitingRemaining;
    return left != null && left <= Duration.zero;
  }

  VendorOrderUiModel copyWith({
    int? backendId,
    String? id,
    String? createdAtLabel,
    VendorOrderStatus? status,
    String? itemsSummary,
    String? totalLabel,
    String? orderType,
    DateTime? awaitingStartedAt,
    bool clearAwaitingStartedAt = false,
    bool? isCustomerContinued,
    bool? showCustomerContinuedBanner,
  }) {
    return VendorOrderUiModel(
      backendId: backendId ?? this.backendId,
      id: id ?? this.id,
      createdAtLabel: createdAtLabel ?? this.createdAtLabel,
      status: status ?? this.status,
      itemsSummary: itemsSummary ?? this.itemsSummary,
      totalLabel: totalLabel ?? this.totalLabel,
      orderType: orderType ?? this.orderType,
      awaitingStartedAt: clearAwaitingStartedAt
          ? null
          : (awaitingStartedAt ?? this.awaitingStartedAt),
      isCustomerContinued: isCustomerContinued ?? this.isCustomerContinued,
      showCustomerContinuedBanner:
          showCustomerContinuedBanner ?? this.showCustomerContinuedBanner,
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
      case VendorOrderStatus.awaitingCustomer:
        // Still waiting on customer — not accepted yet.
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
