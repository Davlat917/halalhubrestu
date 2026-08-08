import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/core/services/vendor_notifications_ws_service.dart';
import 'package:halalhub_restaurant/core/storage/storage.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_status.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_ui_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/models/vendor_orders_item.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/data/orders/orders_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/bloc/orders_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/receipt_printer/services/receipt_printer_service.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc(
    this._repo,
    this._notificationsWs,
    this._receiptPrinter,
    this._storage,
  ) : super(const OrdersState()) {
    on<OrdersLoadRequested>(_onLoad);
    on<OrdersRefreshRequested>(_onRefresh);
    on<OrdersLoadMoreRequested>(_onLoadMore);
    on<OrdersStatusUpdateRequested>(_onStatusUpdate);
    on<OrdersDecisionRequested>(_onDecision);
    on<OrdersAwaitingExpiredRequested>(_onAwaitingExpired);
    on<OrdersCustomerBannerDismissed>(_onBannerDismissed);
    on<OrdersRealtimeOrderCreatedReceived>(_onRealtimeOrderCreated);
    on<OrdersRealtimeStatusSyncReceived>(_onRealtimeStatusSync);

    _loadContinuedBannersFromStorage();
    _wsSubscription = _notificationsWs.events.listen(_onWsEvent);
    _awaitingPollTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (isClosed) return;
      final hasAwaiting = state.items.any(
        (o) => o.status == VendorOrderStatus.awaitingCustomer,
      );
      if (hasAwaiting) add(const OrdersRefreshRequested());
    });
  }

  final OrdersRepository _repo;
  final VendorNotificationsWsService _notificationsWs;
  final ReceiptPrinterService _receiptPrinter;
  final Storage _storage;
  StreamSubscription<VendorWsEvent>? _wsSubscription;
  Timer? _awaitingPollTimer;
  DateTime? _lastRealtimeRefreshAt;
  final Set<int> _awaitingExpiryRefreshInFlight = {};

  /// Local timer starts keyed by order id (survives soft refresh merge).
  final Map<int, DateTime> _awaitingStartedAtByOrderId = {};

  /// Customer continue / auto-continue banners (persisted).
  final Set<int> _customerContinuedBannerOrderIds = {};
  final Set<int> _customerContinuedBannerDismissedIds = {};

  void _loadContinuedBannersFromStorage() {
    _loadIdSetFromStorage(
      _storage.customerContinuedBannerOrderIdsJson(),
      _customerContinuedBannerOrderIds,
    );
    _loadIdSetFromStorage(
      _storage.customerContinuedBannerDismissedIdsJson(),
      _customerContinuedBannerDismissedIds,
    );
  }

  void _loadIdSetFromStorage(String? raw, Set<int> target) {
    if (raw == null || raw.trim().isEmpty) return;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      for (final entry in decoded) {
        final id = (entry as num?)?.toInt() ?? int.tryParse('$entry');
        if (id != null && id > 0) {
          target.add(id);
        }
      }
    } catch (_) {}
  }

  void _markCustomerContinued(int orderBackendId) {
    final added = _customerContinuedBannerOrderIds.add(orderBackendId);
    // New continue cycle → show info banner again.
    final undismissed =
        _customerContinuedBannerDismissedIds.remove(orderBackendId);
    if (!added && !undismissed) return;
    unawaited(
      _storage.customerContinuedBannerOrderIdsJson.set(
        jsonEncode(_customerContinuedBannerOrderIds.toList()),
      ),
    );
    if (undismissed) {
      unawaited(
        _storage.customerContinuedBannerDismissedIdsJson.set(
          jsonEncode(_customerContinuedBannerDismissedIds.toList()),
        ),
      );
    }
  }

  void _dismissCustomerContinuedBanner(int orderBackendId) {
    if (!_customerContinuedBannerDismissedIds.add(orderBackendId)) return;
    unawaited(
      _storage.customerContinuedBannerDismissedIdsJson.set(
        jsonEncode(_customerContinuedBannerDismissedIds.toList()),
      ),
    );
  }

  void _pruneContinuedTracking(Iterable<int> activeBackendIds) {
    final keep = activeBackendIds.toSet();
    final continuedBefore = _customerContinuedBannerOrderIds.length;
    final dismissedBefore = _customerContinuedBannerDismissedIds.length;
    _customerContinuedBannerOrderIds.removeWhere((id) => !keep.contains(id));
    _customerContinuedBannerDismissedIds.removeWhere((id) => !keep.contains(id));
    if (_customerContinuedBannerOrderIds.length != continuedBefore) {
      unawaited(
        _storage.customerContinuedBannerOrderIdsJson.set(
          jsonEncode(_customerContinuedBannerOrderIds.toList()),
        ),
      );
    }
    if (_customerContinuedBannerDismissedIds.length != dismissedBefore) {
      unawaited(
        _storage.customerContinuedBannerDismissedIdsJson.set(
          jsonEncode(_customerContinuedBannerDismissedIds.toList()),
        ),
      );
    }
  }
  List<VendorOrderUiModel> _activeUiItems(
    List<VendorOrdersItem> items, {
    List<VendorOrderUiModel>? previous,
  }) {
    final prevById = <int, VendorOrderUiModel>{
      for (final o in previous ?? const <VendorOrderUiModel>[]) o.backendId: o,
    };
    return items
        .where((item) => !_isTerminalStatus(item.status))
        .map((item) {
          final ui = item.toUiModel();
          final prev = prevById[ui.backendId];
          var next = ui;
          if (ui.status == VendorOrderStatus.awaitingCustomer) {
            final started = _awaitingStartedAtByOrderId[ui.backendId] ??
                prev?.awaitingStartedAt ??
                DateTime.now();
            _awaitingStartedAtByOrderId[ui.backendId] = started;
            next = next.copyWith(awaitingStartedAt: started);
          } else {
            _awaitingStartedAtByOrderId.remove(ui.backendId);
            next = next.copyWith(clearAwaitingStartedAt: true);
          }

          final becameAcceptedFromAwaiting =
              prev?.status == VendorOrderStatus.awaitingCustomer &&
              (ui.status == VendorOrderStatus.accepted ||
                  ui.status == VendorOrderStatus.ready);
          if (becameAcceptedFromAwaiting ||
              prev?.isCustomerContinued == true ||
              prev?.showCustomerContinuedBanner == true) {
            _markCustomerContinued(ui.backendId);
          }

          final continued =
              _customerContinuedBannerOrderIds.contains(ui.backendId) &&
              (ui.status == VendorOrderStatus.accepted ||
                  ui.status == VendorOrderStatus.ready);
          if (continued) {
            final showBanner =
                !_customerContinuedBannerDismissedIds.contains(ui.backendId);
            next = next.copyWith(
              isCustomerContinued: true,
              showCustomerContinuedBanner: showBanner,
            );
          }
          return next;
        })
        .toList();
  }

  bool _isTerminalStatus(String raw) {
    switch (raw.trim().toLowerCase()) {
      case 'delivered':
      case 'completed':
      case 'cancelled':
      case 'canceled':
      case 'delivery_failed':
        return true;
      default:
        return false;
    }
  }

  bool _isTerminalUiStatus(VendorOrderStatus status) {
    return status == VendorOrderStatus.completed ||
        status == VendorOrderStatus.delivered ||
        status == VendorOrderStatus.canceled ||
        status == VendorOrderStatus.deliveryFailed;
  }

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
    if (afterVendorStatusUpdate) {
      unawaited(_notificationsWs.stopNewOrderAlertSound());
    }
  }

  void _printReceiptIfNeeded(int orderBackendId, String? orderNumber) {
    unawaited(
      _receiptPrinter.printNewOrderReceiptFromWs({
        'type': 'order_created',
        'order_id': orderBackendId,
        if (orderNumber != null && orderNumber.isNotEmpty)
          'order_number': orderNumber,
      }),
    );
  }

  void _onWsEvent(VendorWsEvent event) {
    switch (event.type) {
      case VendorWsEventType.orderCreated:
        add(const OrdersRealtimeOrderCreatedReceived());
      case VendorWsEventType.orderStatusUpdated:
      case VendorWsEventType.orderUpdated:
        add(const OrdersRealtimeStatusSyncReceived());
      case VendorWsEventType.unknown:
        break;
    }
  }

  Future<void> _onRealtimeOrderCreated(
    OrdersRealtimeOrderCreatedReceived event,
    Emitter<OrdersState> emit,
  ) async {
    _throttleRefresh();
  }

  Future<void> _onRealtimeStatusSync(
    OrdersRealtimeStatusSyncReceived event,
    Emitter<OrdersState> emit,
  ) async {
    _throttleRefresh();
  }

  void _throttleRefresh() {
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
      final items = _activeUiItems(page.items, previous: state.items);
      _pruneContinuedTracking(items.map((e) => e.backendId));
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
    final quiet = state.items.isNotEmpty;
    if (!quiet) {
      emit(state.copyWith(status: OrdersLoadStatus.loading, clearError: true));
    }
    try {
      final page = await _repo.fetchOrders();
      final previous = state.items;
      final items = _activeUiItems(page.items, previous: previous);
      _pruneContinuedTracking(items.map((e) => e.backendId));

      int? bannerOrderId = state.listBannerOrderId;
      String? bannerOrderNumber = state.listBannerOrderNumber;
      for (final next in items) {
        VendorOrderUiModel? prev;
        for (final p in previous) {
          if (p.backendId == next.backendId) {
            prev = p;
            break;
          }
        }
        if (prev?.status == VendorOrderStatus.awaitingCustomer &&
            (next.status == VendorOrderStatus.accepted ||
                next.status == VendorOrderStatus.ready)) {
          _markCustomerContinued(next.backendId);
          bannerOrderId = next.backendId;
          bannerOrderNumber = next.id;
          _printReceiptIfNeeded(next.backendId, next.id);
        }
      }

      // Awaiting order cancelled by customer → dropped from active list.
      for (final prev in previous) {
        if (prev.status != VendorOrderStatus.awaitingCustomer) continue;
        final stillPresent = items.any((n) => n.backendId == prev.backendId);
        if (!stillPresent) {
          _awaitingStartedAtByOrderId.remove(prev.backendId);
        }
      }

      emit(
        state.copyWith(
          status: OrdersLoadStatus.success,
          items: items,
          setNextPageUrl: true,
          nextPageUrl: page.nextPageUrl,
          setCount: true,
          count: page.count,
          clearError: true,
          listBannerOrderId: bannerOrderId,
          listBannerOrderNumber: bannerOrderNumber,
        ),
      );
      _syncNewOrderAlertSound(items);
    } catch (e) {
      emit(
        state.copyWith(
          status: quiet ? state.status : OrdersLoadStatus.failure,
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
      final newItems = _activeUiItems(page.items, previous: state.items);
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
      final isTerminal = _isTerminalUiStatus(nextUiStatus);

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

  /// Applies authoritative API status after decision / detail poll.
  void _applyServerStatus({
    required int orderBackendId,
    required VendorOrderStatus nextStatus,
    required String? orderNumber,
    required Emitter<OrdersState> emit,
    bool clearDecisionLoading = false,
    bool showContinuedBanner = false,
    bool printReceipt = false,
  }) {
    if (_isTerminalUiStatus(nextStatus)) {
      final updated = state.items
          .where((o) => o.backendId != orderBackendId)
          .toList();
      _awaitingStartedAtByOrderId.remove(orderBackendId);
      emit(
        state.copyWith(
          items: updated,
          clearDecisionLoading: clearDecisionLoading,
        ),
      );
      _syncNewOrderAlertSound(updated, afterVendorStatusUpdate: true);
      return;
    }

    if (nextStatus == VendorOrderStatus.awaitingCustomer) {
      final started =
          _awaitingStartedAtByOrderId[orderBackendId] ?? DateTime.now();
      _awaitingStartedAtByOrderId[orderBackendId] = started;
      final updated = <VendorOrderUiModel>[];
      for (final order in state.items) {
        if (order.backendId != orderBackendId) {
          updated.add(order);
          continue;
        }
        updated.add(
          order.copyWith(
            status: VendorOrderStatus.awaitingCustomer,
            awaitingStartedAt: started,
          ),
        );
      }
      emit(
        state.copyWith(
          items: updated,
          clearDecisionLoading: clearDecisionLoading,
        ),
      );
      _syncNewOrderAlertSound(updated, afterVendorStatusUpdate: true);
      return;
    }

    // confirmed / preparing / ready — treat as accepted for active board.
    VendorOrderUiModel? matched;
    final updated = <VendorOrderUiModel>[];
    for (final order in state.items) {
      if (order.backendId != orderBackendId) {
        updated.add(order);
        continue;
      }
      matched = order;
      final resolvedStatus = nextStatus == VendorOrderStatus.newOrder
          ? VendorOrderStatus.accepted
          : nextStatus;
      if (showContinuedBanner) {
        _markCustomerContinued(orderBackendId);
      }
      final continued = showContinuedBanner ||
          _customerContinuedBannerOrderIds.contains(orderBackendId);
      updated.add(
        order.copyWith(
          status: resolvedStatus,
          clearAwaitingStartedAt: true,
          isCustomerContinued: continued,
          showCustomerContinuedBanner: continued &&
              !_customerContinuedBannerDismissedIds.contains(orderBackendId),
        ),
      );
    }
    _awaitingStartedAtByOrderId.remove(orderBackendId);
    emit(
      state.copyWith(
        items: updated,
        clearDecisionLoading: clearDecisionLoading,
        listBannerOrderId:
            showContinuedBanner ? orderBackendId : state.listBannerOrderId,
        listBannerOrderNumber: showContinuedBanner
            ? (orderNumber ?? matched?.id)
            : state.listBannerOrderNumber,
      ),
    );
    if (printReceipt) {
      _printReceiptIfNeeded(orderBackendId, orderNumber ?? matched?.id);
    }
    _syncNewOrderAlertSound(updated, afterVendorStatusUpdate: true);
  }

  Future<void> _onDecision(
    OrdersDecisionRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(
      state.copyWith(
        decisionLoadingOrderId: event.orderBackendId,
        clearError: true,
      ),
    );
    try {
      final result = await _repo.submitOrderDecision(
        orderId: event.orderBackendId,
        action: event.action,
        unavailableItemIds: event.unavailableItemIds,
      );
      var nextStatus = VendorOrdersItem.statusFromApi(result.status);

      // Partial unavailable must pause for customer — never treat as full confirm.
      if (event.action.trim().toLowerCase() == 'confirm' &&
          event.unavailableItemIds.isNotEmpty &&
          nextStatus == VendorOrderStatus.accepted) {
        nextStatus = VendorOrderStatus.awaitingCustomer;
      }

      final printReceipt = nextStatus == VendorOrderStatus.accepted;

      _applyServerStatus(
        orderBackendId: event.orderBackendId,
        nextStatus: nextStatus,
        orderNumber: result.orderNumber,
        emit: emit,
        clearDecisionLoading: true,
        printReceipt: printReceipt,
      );
    } catch (e) {
      emit(
        state.copyWith(
          clearDecisionLoading: true,
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> _onAwaitingExpired(
    OrdersAwaitingExpiredRequested event,
    Emitter<OrdersState> emit,
  ) async {
    if (_awaitingExpiryRefreshInFlight.contains(event.orderBackendId)) return;
    VendorOrderUiModel? current;
    for (final o in state.items) {
      if (o.backendId == event.orderBackendId) {
        current = o;
        break;
      }
    }
    if (current == null ||
        current.status != VendorOrderStatus.awaitingCustomer) {
      return;
    }

    // Server auto-continues on timeout — do NOT re-POST decision.
    _awaitingExpiryRefreshInFlight.add(event.orderBackendId);
    try {
      final detail = await _repo.fetchOrderDetail(
        orderId: event.orderBackendId,
      );
      final nextStatus = VendorOrdersItem.statusFromApi(detail.status);

      if (nextStatus == VendorOrderStatus.awaitingCustomer) {
        // Server not finished yet; 12s poll / WS will catch the change.
        return;
      }

      final fromAwaiting = true;
      final becameAccepted = nextStatus == VendorOrderStatus.accepted ||
          nextStatus == VendorOrderStatus.ready;
      _applyServerStatus(
        orderBackendId: event.orderBackendId,
        nextStatus: nextStatus,
        orderNumber: detail.displayOrderNumber,
        emit: emit,
        showContinuedBanner: fromAwaiting && becameAccepted,
        printReceipt: becameAccepted,
      );
    } catch (e) {
      // Fall back to list refresh; poll continues either way.
      add(const OrdersRefreshRequested());
      emit(
        state.copyWith(
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    } finally {
      _awaitingExpiryRefreshInFlight.remove(event.orderBackendId);
    }
  }

  void _onBannerDismissed(
    OrdersCustomerBannerDismissed event,
    Emitter<OrdersState> emit,
  ) {
    _dismissCustomerContinuedBanner(event.orderBackendId);
    final updated = <VendorOrderUiModel>[];
    for (final order in state.items) {
      if (order.backendId != event.orderBackendId) {
        updated.add(order);
        continue;
      }
      updated.add(order.copyWith(showCustomerContinuedBanner: false));
    }
    final clearBanner = state.listBannerOrderId == event.orderBackendId;
    emit(
      state.copyWith(
        items: updated,
        clearListBanner: clearBanner,
      ),
    );
  }

  @override
  Future<void> close() async {
    _awaitingPollTimer?.cancel();
    await _wsSubscription?.cancel();
    return super.close();
  }
}
