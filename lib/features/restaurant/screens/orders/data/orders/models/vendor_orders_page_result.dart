import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_orders_item.dart';

class VendorOrdersPageResult extends Equatable {
  const VendorOrdersPageResult({
    required this.items,
    this.count,
    this.nextPageUrl,
    this.previousPageUrl,
  });

  final List<VendorOrdersItem> items;
  final int? count;
  final String? nextPageUrl;
  final String? previousPageUrl;

  factory VendorOrdersPageResult.fromJson(Map<String, dynamic> json) {
    final raw = json['results'];
    final list = <VendorOrdersItem>[];
    if (raw is List) {
      for (final row in raw) {
        if (row is Map) {
          list.add(VendorOrdersItem.fromJson(Map<String, dynamic>.from(row)));
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
    return VendorOrdersPageResult(
      items: list,
      count: count,
      nextPageUrl: json['next'] as String?,
      previousPageUrl: json['previous'] as String?,
    );
  }

  @override
  List<Object?> get props => [items, count, nextPageUrl, previousPageUrl];
}
