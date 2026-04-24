import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/data/models/notification_item_model.dart';

enum NotificationsLoadStatus { initial, loading, success, failure }

class NotificationState extends Equatable {
  const NotificationState({
    this.status = NotificationsLoadStatus.initial,
    this.items = const [],
    this.nextPageUrl,
    this.count,
    this.errorMessage,
    this.isLoadingMore = false,
  });

  final NotificationsLoadStatus status;
  final List<NotificationItemModel> items;
  final String? nextPageUrl;
  final int? count;
  final String? errorMessage;
  final bool isLoadingMore;

  bool get hasMore => nextPageUrl != null && nextPageUrl!.isNotEmpty;

  NotificationState copyWith({
    NotificationsLoadStatus? status,
    List<NotificationItemModel>? items,
    String? nextPageUrl,
    bool setNextPageUrl = false,
    int? count,
    bool setCount = false,
    String? errorMessage,
    bool clearError = false,
    bool? isLoadingMore,
  }) {
    return NotificationState(
      status: status ?? this.status,
      items: items ?? this.items,
      nextPageUrl: setNextPageUrl ? nextPageUrl : this.nextPageUrl,
      count: setCount ? count : this.count,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [status, items, nextPageUrl, count, errorMessage, isLoadingMore];
}
