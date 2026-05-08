import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/core/services/vendor_notifications_ws_service.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_status.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_ui_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_orders_item.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/orders_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc(this._repo, this._notificationsWs) : super(const OrdersState()) {
    on<OrdersLoadRequested>(_onLoad);
    on<OrdersRefreshRequested>(_onRefresh);
    on<OrdersLoadMoreRequested>(_onLoadMore);
    on<OrdersStatusUpdateRequested>(_onStatusUpdate);
    on<OrdersRealtimeOrderCreatedReceived>(_onRealtimeOrderCreated);

    _wsSubscription = _notificationsWs.events.listen(_onWsEvent);
  }

  final OrdersRepository _repo;
  final VendorNotificationsWsService _notificationsWs;
  StreamSubscription<VendorWsEvent>? _wsSubscription;
  DateTime? _lastRealtimeRefreshAt;

  void _syncNewOrderAlertSound(
    List<VendorOrderUiModel> items, {
    bool afterVendorStatusUpdate = false,
  }) {
    final hasPendingNewOrders = items.any(
      (order) => order.status == VendorOrderStatus.newOrder,
    );
    if (hasPendingNewOrders) {
      unawaited(_notificationsWs.startNewOrderAlertSoundLoop());
      return;
    }
    // Ro'yxat yuklash/refresh ovozni o'chirmaydi — faqat dialog tugmalari yoki
    // buyurtma statusini API orqali o'zgartirganda.
    if (afterVendorStatusUpdate) {
      unawaited(_notificationsWs.stopNewOrderAlertSound());
    }
  }

  void _onWsEvent(VendorWsEvent event) {
    if (event.type != VendorWsEventType.orderCreated) return;
    add(const OrdersRealtimeOrderCreatedReceived());
  }

  Future<void> _onRealtimeOrderCreated(
    OrdersRealtimeOrderCreatedReceived event,
    Emitter<OrdersState> emit,
  ) async {
    if (state.status == OrdersLoadStatus.loading || state.isLoadingMore) return;
    final now = DateTime.now();
    final last = _lastRealtimeRefreshAt;
    if (last != null && now.difference(last).inMilliseconds < 1500) return;
    _lastRealtimeRefreshAt = now;
    add(const OrdersRefreshRequested());
  }

  Future<void> _onLoad(
    OrdersLoadRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(status: OrdersLoadStatus.loading, clearError: true));
    try {
      final page = await _repo.fetchOrders();
      final items = page.items.map((e) => e.toUiModel()).toList();
      emit(
        state.copyWith(
          status: OrdersLoadStatus.success,
          items: items,
          setNextPageUrl: true,
          nextPageUrl: page.nextPageUrl,
          setCount: true,
          count: page.count,
          clearError: true,
        ),
      );
      _syncNewOrderAlertSound(items);
    } catch (e) {
      emit(
        state.copyWith(
          status: OrdersLoadStatus.failure,
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> _onRefresh(
    OrdersRefreshRequested event,
    Emitter<OrdersState> emit,
  ) async {
    if (state.status == OrdersLoadStatus.loading) return;
    emit(state.copyWith(status: OrdersLoadStatus.loading, clearError: true));
    try {
      final page = await _repo.fetchOrders();
      final items = page.items.map((e) => e.toUiModel()).toList();
      emit(
        state.copyWith(
          status: OrdersLoadStatus.success,
          items: items,
          setNextPageUrl: true,
          nextPageUrl: page.nextPageUrl,
          setCount: true,
          count: page.count,
          clearError: true,
        ),
      );
      _syncNewOrderAlertSound(items);
    } catch (e) {
      emit(
        state.copyWith(
          status: OrdersLoadStatus.failure,
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadMore(
    OrdersLoadMoreRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final url = state.nextPageUrl;
    if (url == null || url.isEmpty || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final page = await _repo.fetchOrders(nextPageUrl: url);
      final newItems = page.items.map((e) => e.toUiModel()).toList();
      emit(
        state.copyWith(
          status: OrdersLoadStatus.success,
          items: [...state.items, ...newItems],
          setNextPageUrl: true,
          nextPageUrl: page.nextPageUrl,
          setCount: true,
          count: page.count ?? state.count,
          isLoadingMore: false,
          clearError: true,
        ),
      );
      _syncNewOrderAlertSound([...state.items, ...newItems]);
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingMore: false,
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> _onStatusUpdate(
    OrdersStatusUpdateRequested event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      await _repo.updateOrderStatus(
        orderId: event.orderBackendId,
        status: event.nextStatusApi,
      );
      final nextUiStatus = VendorOrdersItem.statusFromApi(event.nextStatusApi);
      final isTerminal =
          nextUiStatus == VendorOrderStatus.completed ||
          nextUiStatus == VendorOrderStatus.delivered ||
          nextUiStatus == VendorOrderStatus.canceled ||
          nextUiStatus == VendorOrderStatus.deliveryFailed;

      final updated = <VendorOrderUiModel>[];
      for (final order in state.items) {
        if (order.backendId != event.orderBackendId) {
          updated.add(order);
          continue;
        }
        if (!isTerminal) {
          updated.add(order.copyWith(status: nextUiStatus));
        }
      }
      emit(state.copyWith(items: updated));
      _syncNewOrderAlertSound(updated, afterVendorStatusUpdate: true);
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _wsSubscription?.cancel();
    return super.close();
  }
}
