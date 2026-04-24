import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/order_history/order_history_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/screens/order_history/bloc/order_history_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/screens/order_history/bloc/order_history_state.dart';

class OrderHistoryBloc extends Bloc<OrderHistoryEvent, OrderHistoryState> {
  OrderHistoryBloc(this._repo) : super(const OrderHistoryState()) {
    on<OrderHistoryLoadRequested>(_onLoad);
    on<OrderHistoryRefreshRequested>(_onRefresh);
    on<OrderHistoryLoadMoreRequested>(_onLoadMore);
  }

  final OrderHistoryRepository _repo;

  Future<void> _onLoad(OrderHistoryLoadRequested event, Emitter<OrderHistoryState> emit) async {
    emit(state.copyWith(status: OrderHistoryLoadStatus.loading, clearError: true));
    try {
      final page = await _repo.fetchOrderHistory();
      final items = page.items.map((e) => e.toUiModel()).toList();
      emit(
        state.copyWith(
          status: OrderHistoryLoadStatus.success,
          items: items,
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
          status: OrderHistoryLoadStatus.failure,
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefresh(OrderHistoryRefreshRequested event, Emitter<OrderHistoryState> emit) async {
    if (state.status == OrderHistoryLoadStatus.loading) return;
    emit(state.copyWith(status: OrderHistoryLoadStatus.loading, clearError: true));
    try {
      final page = await _repo.fetchOrderHistory();
      final items = page.items.map((e) => e.toUiModel()).toList();
      emit(
        state.copyWith(
          status: OrderHistoryLoadStatus.success,
          items: items,
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
          status: OrderHistoryLoadStatus.failure,
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMore(OrderHistoryLoadMoreRequested event, Emitter<OrderHistoryState> emit) async {
    final url = state.nextPageUrl;
    if (url == null || url.isEmpty || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final page = await _repo.fetchOrderHistory(nextPageUrl: url);
      final newItems = page.items.map((e) => e.toUiModel()).toList();
      emit(
        state.copyWith(
          status: OrderHistoryLoadStatus.success,
          items: [...state.items, ...newItems],
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
