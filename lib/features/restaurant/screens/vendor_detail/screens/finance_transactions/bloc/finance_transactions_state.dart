import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_period.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_transaction_item_model.dart';

enum FinanceTransactionsLoadStatus { initial, loading, success, failure }

class FinanceTransactionsState extends Equatable {
  const FinanceTransactionsState({
    this.status = FinanceTransactionsLoadStatus.initial,
    this.period = VendorFinancePeriod.weekly,
    this.transactions = const [],
    this.totalAmount = 0,
    this.totalOrders = 0,
    this.currency = 'usd',
    this.dateFrom = '',
    this.dateTo = '',
    this.nextPageUrl,
    this.isLoadingMore = false,
    this.errorMessage,
  });

  final FinanceTransactionsLoadStatus status;
  final VendorFinancePeriod period;
  final List<VendorFinanceTransactionItemModel> transactions;
  final double totalAmount;
  final int totalOrders;
  final String currency;
  final String dateFrom;
  final String dateTo;
  final String? nextPageUrl;
  final bool isLoadingMore;
  final String? errorMessage;

  bool get hasMore => nextPageUrl != null && nextPageUrl!.trim().isNotEmpty;

  FinanceTransactionsState copyWith({
    FinanceTransactionsLoadStatus? status,
    VendorFinancePeriod? period,
    List<VendorFinanceTransactionItemModel>? transactions,
    double? totalAmount,
    int? totalOrders,
    String? currency,
    String? dateFrom,
    String? dateTo,
    String? nextPageUrl,
    bool setNextPageUrl = false,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FinanceTransactionsState(
      status: status ?? this.status,
      period: period ?? this.period,
      transactions: transactions ?? this.transactions,
      totalAmount: totalAmount ?? this.totalAmount,
      totalOrders: totalOrders ?? this.totalOrders,
      currency: currency ?? this.currency,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      nextPageUrl: setNextPageUrl ? nextPageUrl : (nextPageUrl ?? this.nextPageUrl),
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        period,
        transactions,
        totalAmount,
        totalOrders,
        currency,
        dateFrom,
        dateTo,
        nextPageUrl,
        isLoadingMore,
        errorMessage,
      ];
}
