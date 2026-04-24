import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/bloc/notification_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/bloc/notification_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/data/notifications_repository.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  NotificationBloc(this._repo) : super(const NotificationState()) {
    on<NotificationsLoadRequested>(_onLoad);
    on<NotificationsRefreshRequested>(_onRefresh);
    on<NotificationsLoadMoreRequested>(_onLoadMore);
  }

  final NotificationsRepository _repo;

  Future<void> _onLoad(NotificationsLoadRequested event, Emitter<NotificationState> emit) async {
    emit(state.copyWith(status: NotificationsLoadStatus.loading, clearError: true));
    try {
      final page = await _repo.fetchNotifications();
      emit(
        state.copyWith(
          status: NotificationsLoadStatus.success,
          items: page.items,
          setNextPageUrl: true,
          nextPageUrl: page.nextPageUrl,
          setCount: true,
          count: page.count,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationsLoadStatus.failure,
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefresh(NotificationsRefreshRequested event, Emitter<NotificationState> emit) async {
    if (state.status == NotificationsLoadStatus.loading) return;
    emit(state.copyWith(status: NotificationsLoadStatus.loading, clearError: true));
    try {
      final page = await _repo.fetchNotifications();
      emit(
        state.copyWith(
          status: NotificationsLoadStatus.success,
          items: page.items,
          setNextPageUrl: true,
          nextPageUrl: page.nextPageUrl,
          setCount: true,
          count: page.count,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: NotificationsLoadStatus.failure,
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMore(NotificationsLoadMoreRequested event, Emitter<NotificationState> emit) async {
    final url = state.nextPageUrl;
    if (url == null || url.isEmpty || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final page = await _repo.fetchNotifications(nextPageUrl: url);
      emit(
        state.copyWith(
          status: NotificationsLoadStatus.success,
          items: [...state.items, ...page.items],
          setNextPageUrl: true,
          nextPageUrl: page.nextPageUrl,
          setCount: true,
          count: page.count ?? state.count,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }
}
