import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/models/vendor_finance_period.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/data/repositories/finance_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/bloc/finance_transactions_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_detail/screens/finance_transactions/bloc/finance_transactions_state.dart';

class FinanceTransactionsBloc
    extends Bloc<FinanceTransactionsEvent, FinanceTransactionsState> {
  FinanceTransactionsBloc(this._repo) : super(const FinanceTransactionsState()) {
    on<FinanceTransactionsLoadRequested>(_onLoad);
    on<FinanceTransactionsPeriodChanged>(_onPeriodChanged);
    on<FinanceTransactionsRefreshRequested>(_onRefresh);
    on<FinanceTransactionsLoadMoreRequested>(_onLoadMore);
  }

  final FinanceRepository _repo;

  Future<void> _onLoad(
    FinanceTransactionsLoadRequested event,
    Emitter<FinanceTransactionsState> emit,
  ) async {
    emit(
      state.copyWith(
        status: FinanceTransactionsLoadStatus.loading,
        period: event.period,
        clearError: true,
      ),
    );
    await _fetchFirstPage(emit, event.period);
  }

  Future<void> _onPeriodChanged(
    FinanceTransactionsPeriodChanged event,
    Emitter<FinanceTransactionsState> emit,
  ) async {
    if (state.period == event.period &&
        state.status == FinanceTransactionsLoadStatus.success) {
      return;
    }
    add(FinanceTransactionsLoadRequested(period: event.period));
  }

  Future<void> _onRefresh(
    FinanceTransactionsRefreshRequested event,
    Emitter<FinanceTransactionsState> emit,
  ) async {
    if (state.status == FinanceTransactionsLoadStatus.loading) return;
    emit(
      state.copyWith(
        status: FinanceTransactionsLoadStatus.loading,
        clearError: true,
      ),
    );
    await _fetchFirstPage(emit, state.period);
  }

  Future<void> _onLoadMore(
    FinanceTransactionsLoadMoreRequested event,
    Emitter<FinanceTransactionsState> emit,
  ) async {
    final url = state.nextPageUrl;
    if (url == null || url.isEmpty || state.isLoadingMore) return;
    emit(state.copyWith(isLoadingMore: true, clearError: true));
    try {
      final page = await _repo.fetchTransactions(
        period: state.period,
        nextPageUrl: url,
      );
      emit(
        state.copyWith(
          status: FinanceTransactionsLoadStatus.success,
          transactions: [...state.transactions, ...page.results],
          setNextPageUrl: true,
          nextPageUrl: page.next,
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

  Future<void> _fetchFirstPage(
    Emitter<FinanceTransactionsState> emit,
    VendorFinancePeriod period,
  ) async {
    try {
      final page = await _repo.fetchTransactions(period: period);
      emit(
        state.copyWith(
          status: FinanceTransactionsLoadStatus.success,
          period: page.period,
          transactions: page.results,
          totalAmount: page.totalAmount,
          totalOrders: page.totalOrders,
          currency: page.currency,
          dateFrom: page.dateFrom,
          dateTo: page.dateTo,
          setNextPageUrl: true,
          nextPageUrl: page.next,
          isLoadingMore: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FinanceTransactionsLoadStatus.failure,
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }
}
