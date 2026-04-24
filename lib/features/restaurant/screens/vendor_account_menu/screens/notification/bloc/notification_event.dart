import 'package:equatable/equatable.dart';

sealed class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

final class NotificationsLoadRequested extends NotificationEvent {
  const NotificationsLoadRequested();
}

final class NotificationsRefreshRequested extends NotificationEvent {
  const NotificationsRefreshRequested();
}

final class NotificationsLoadMoreRequested extends NotificationEvent {
  const NotificationsLoadMoreRequested();
}
