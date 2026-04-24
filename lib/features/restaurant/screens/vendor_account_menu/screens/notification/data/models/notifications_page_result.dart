import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/data/models/notification_item_model.dart';

class NotificationsPageResult extends Equatable {
  const NotificationsPageResult({
    required this.items,
    this.count,
    this.nextPageUrl,
    this.previousPageUrl,
  });

  final List<NotificationItemModel> items;
  final int? count;
  final String? nextPageUrl;
  final String? previousPageUrl;

  factory NotificationsPageResult.fromJson(Map<String, dynamic> json) {
    final raw = json['results'];
    final list = <NotificationItemModel>[];
    if (raw is List) {
      for (final row in raw) {
        if (row is Map) {
          list.add(
            NotificationItemModel.fromJson(Map<String, dynamic>.from(row)),
          );
        }
      }
    }
    return NotificationsPageResult(
      items: list,
      count: json['count'] as int?,
      nextPageUrl: json['next'] as String?,
      previousPageUrl: json['previous'] as String?,
    );
  }

  @override
  List<Object?> get props => [items, count, nextPageUrl, previousPageUrl];
}
