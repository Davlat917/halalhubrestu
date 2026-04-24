import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/order_history/models/vendor_order_history_item.dart';

class VendorOrderHistoryPageResult extends Equatable {
  const VendorOrderHistoryPageResult({
    required this.items,
    this.count,
    this.nextPageUrl,
    this.previousPageUrl,
  });

  final List<VendorOrderHistoryItem> items;
  final int? count;
  final String? nextPageUrl;
  final String? previousPageUrl;

  factory VendorOrderHistoryPageResult.fromJson(Map<String, dynamic> json) {
    final raw = json['results'];
    final list = <VendorOrderHistoryItem>[];
    if (raw is List) {
      for (final row in raw) {
        if (row is Map) {
          list.add(
            VendorOrderHistoryItem.fromJson(Map<String, dynamic>.from(row)),
          );
        }
      }
    }
    final countRaw = json['count'];
    int? count;
    if (countRaw is int) {
      count = countRaw;
    } else if (countRaw is num) {
      count = countRaw.toInt();
    }
    return VendorOrderHistoryPageResult(
      items: list,
      count: count,
      nextPageUrl: json['next'] as String?,
      previousPageUrl: json['previous'] as String?,
    );
  }

  @override
  List<Object?> get props => [items, count, nextPageUrl, previousPageUrl];
}
