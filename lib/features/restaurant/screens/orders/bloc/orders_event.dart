import 'package:equatable/equatable.dart';

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

final class OrdersLoadRequested extends OrdersEvent {
  const OrdersLoadRequested();
}

final class OrdersRefreshRequested extends OrdersEvent {
  const OrdersRefreshRequested();
}

final class OrdersLoadMoreRequested extends OrdersEvent {
  const OrdersLoadMoreRequested();
}

final class OrdersStatusUpdateRequested extends OrdersEvent {
  const OrdersStatusUpdateRequested({
    required this.orderBackendId,
    required this.nextStatusApi,
  });

  final int orderBackendId;
  final String nextStatusApi;

  @override
  List<Object?> get props => [orderBackendId, nextStatusApi];
}

/// Card Confirm / Cancel yoki detail Accept.
final class OrdersDecisionRequested extends OrdersEvent {
  const OrdersDecisionRequested({
    required this.orderBackendId,
    required this.action,
    this.unavailableItemIds = const [],
  });

  final int orderBackendId;
  final String action;
  final List<int> unavailableItemIds;

  @override
  List<Object?> get props => [orderBackendId, action, unavailableItemIds];
}

final class OrdersAwaitingExpiredRequested extends OrdersEvent {
  const OrdersAwaitingExpiredRequested({required this.orderBackendId});

  final int orderBackendId;

  @override
  List<Object?> get props => [orderBackendId];
}

final class OrdersCustomerBannerDismissed extends OrdersEvent {
  const OrdersCustomerBannerDismissed({required this.orderBackendId});

  final int orderBackendId;

  @override
  List<Object?> get props => [orderBackendId];
}

final class OrdersRealtimeOrderCreatedReceived extends OrdersEvent {
  const OrdersRealtimeOrderCreatedReceived();
}

/// WS `order_status_updated` / `order_updated` — sync list after customer/server decision.
final class OrdersRealtimeStatusSyncReceived extends OrdersEvent {
  const OrdersRealtimeStatusSyncReceived();
}
