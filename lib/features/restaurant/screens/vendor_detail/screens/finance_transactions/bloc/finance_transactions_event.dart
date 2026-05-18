import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_period.dart';

sealed class FinanceTransactionsEvent extends Equatable {
  const FinanceTransactionsEvent();

  @override
  List<Object?> get props => [];
}

final class FinanceTransactionsLoadRequested extends FinanceTransactionsEvent {
  const FinanceTransactionsLoadRequested({required this.period});

  final VendorFinancePeriod period;

  @override
  List<Object?> get props => [period];
}

final class FinanceTransactionsPeriodChanged extends FinanceTransactionsEvent {
  const FinanceTransactionsPeriodChanged({required this.period});

  final VendorFinancePeriod period;

  @override
  List<Object?> get props => [period];
}

final class FinanceTransactionsRefreshRequested extends FinanceTransactionsEvent {
  const FinanceTransactionsRefreshRequested();
}

final class FinanceTransactionsLoadMoreRequested extends FinanceTransactionsEvent {
  const FinanceTransactionsLoadMoreRequested();
}
