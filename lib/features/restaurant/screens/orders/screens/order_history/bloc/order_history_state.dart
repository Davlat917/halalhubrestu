import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_ui_model.dart';

enum OrderHistoryLoadStatus { initial, loading, success, failure }

class OrderHistoryState extends Equatable {
  const OrderHistoryState({
    this.status = OrderHistoryLoadStatus.initial,
    this.items = const [],
    this.nextPageUrl,
    this.count,
    this.errorMessage,
    this.isLoadingMore = false,
  });

  final OrderHistoryLoadStatus status;
  final List<VendorOrderUiModel> items;
  final String? nextPageUrl;
  final int? count;
  final String? errorMessage;
  final bool isLoadingMore;

  bool get hasMore => nextPageUrl != null && nextPageUrl!.isNotEmpty;

  OrderHistoryState copyWith({
    OrderHistoryLoadStatus? status,
    List<VendorOrderUiModel>? items,
    String? nextPageUrl,
    bool setNextPageUrl = false,
    int? count,
    bool setCount = false,
    String? errorMessage,
    bool clearError = false,
    bool? isLoadingMore,
  }) {
    return OrderHistoryState(
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
