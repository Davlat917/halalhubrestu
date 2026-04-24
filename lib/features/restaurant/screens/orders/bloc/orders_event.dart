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

final class OrdersRealtimeOrderCreatedReceived extends OrdersEvent {
  const OrdersRealtimeOrderCreatedReceived();
}
