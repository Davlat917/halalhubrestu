import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_period.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_transaction_item_model.dart';

class VendorFinanceTransactionsPageModel extends Equatable {
  const VendorFinanceTransactionsPageModel({
    required this.period,
    required this.dateFrom,
    required this.dateTo,
    required this.totalAmount,
    required this.totalOrders,
    required this.currency,
    required this.results,
    required this.count,
    this.next,
    this.previous,
  });

  final VendorFinancePeriod period;
  final String dateFrom;
  final String dateTo;
  final double totalAmount;
  final int totalOrders;
  final String currency;
  final List<VendorFinanceTransactionItemModel> results;
  final int count;
  final String? next;
  final String? previous;

  factory VendorFinanceTransactionsPageModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawResults = json['results'];
    final results = <VendorFinanceTransactionItemModel>[];
    if (rawResults is List) {
      for (final e in rawResults) {
        if (e is Map) {
          results.add(
            VendorFinanceTransactionItemModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          );
        }
      }
    }

    return VendorFinanceTransactionsPageModel(
      period: VendorFinancePeriod.fromApiValue(json['period']?.toString()),
      dateFrom: json['date_from']?.toString() ?? '',
      dateTo: json['date_to']?.toString() ?? '',
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      totalOrders: (json['total_orders'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'usd',
      results: results,
      count: (json['count'] as num?)?.toInt() ?? results.length,
      next: json['next']?.toString(),
      previous: json['previous']?.toString(),
    );
  }

  bool get hasMore => next != null && next!.trim().isNotEmpty;

  @override
  List<Object?> get props => [
        period,
        dateFrom,
        dateTo,
        totalAmount,
        totalOrders,
        currency,
        results,
        count,
        next,
        previous,
      ];
}
