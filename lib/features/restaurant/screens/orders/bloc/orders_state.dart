import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/orders/models/vendor_order_ui_model.dart';

enum OrdersLoadStatus { initial, loading, success, failure }

class OrdersState extends Equatable {
  const OrdersState({
    this.status = OrdersLoadStatus.initial,
    this.items = const [],
    this.nextPageUrl,
    this.count,
    this.errorMessage,
    this.isLoadingMore = false,
    this.decisionLoadingOrderId,
    this.listBannerOrderId,
    this.listBannerOrderNumber,
  });

  final OrdersLoadStatus status;
  final List<VendorOrderUiModel> items;
  final String? nextPageUrl;
  final int? count;
  final String? errorMessage;
  final bool isLoadingMore;
  final int? decisionLoadingOrderId;
  final int? listBannerOrderId;
  final String? listBannerOrderNumber;

  bool get hasMore => nextPageUrl != null && nextPageUrl!.isNotEmpty;

  OrdersState copyWith({
    OrdersLoadStatus? status,
    List<VendorOrderUiModel>? items,
    String? nextPageUrl,
    bool setNextPageUrl = false,
    int? count,
    bool setCount = false,
    String? errorMessage,
    bool clearError = false,
    bool? isLoadingMore,
    int? decisionLoadingOrderId,
    bool clearDecisionLoading = false,
    int? listBannerOrderId,
    String? listBannerOrderNumber,
    bool clearListBanner = false,
  }) {
    return OrdersState(
      status: status ?? this.status,
      items: items ?? this.items,
      nextPageUrl: setNextPageUrl ? nextPageUrl : this.nextPageUrl,
      count: setCount ? count : this.count,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      decisionLoadingOrderId: clearDecisionLoading
          ? null
          : (decisionLoadingOrderId ?? this.decisionLoadingOrderId),
      listBannerOrderId: clearListBanner
          ? null
          : (listBannerOrderId ?? this.listBannerOrderId),
      listBannerOrderNumber: clearListBanner
          ? null
          : (listBannerOrderNumber ?? this.listBannerOrderNumber),
    );
  }

  @override
  List<Object?> get props => [
        status,
        items,
        nextPageUrl,
        count,
        errorMessage,
        isLoadingMore,
        decisionLoadingOrderId,
        listBannerOrderId,
        listBannerOrderNumber,
      ];
}
