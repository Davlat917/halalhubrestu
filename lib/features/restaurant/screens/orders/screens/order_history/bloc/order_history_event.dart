import 'package:equatable/equatable.dart';

sealed class OrderHistoryEvent extends Equatable {
  const OrderHistoryEvent();

  @override
  List<Object?> get props => [];
}

final class OrderHistoryLoadRequested extends OrderHistoryEvent {
  const OrderHistoryLoadRequested();
}

final class OrderHistoryRefreshRequested extends OrderHistoryEvent {
  const OrderHistoryRefreshRequested();
}

final class OrderHistoryLoadMoreRequested extends OrderHistoryEvent {
  const OrderHistoryLoadMoreRequested();
}
