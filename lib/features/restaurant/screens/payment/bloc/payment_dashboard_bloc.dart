import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_bank_info/vendor_bank_info_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_payout_request/vendor_payout_request_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_wallet_dashboard/vendor_wallet_dashboard_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/repositories/restaurant_repo.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/bloc/payment_dashboard_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/models/payment_history_row.dart';

class PaymentDashboardBloc
    extends Bloc<PaymentDashboardEvent, PaymentDashboardState> {
  PaymentDashboardBloc(this._repo) : super(const PaymentDashboardState()) {
    on<PaymentDashboardRequested>(_onRequested);
    on<PaymentBankInfoUpdateRequested>(_onBankInfoUpdateRequested);
    on<PaymentBankInfoUpdateStatusCleared>(_onBankInfoUpdateStatusCleared);
    on<PaymentPayoutHistoryLoadMore>(_onPayoutHistoryLoadMore);
    on<PaymentWithdrawRequestSubmitted>(_onWithdrawRequestSubmitted);
    on<PaymentWithdrawRequestStatusCleared>(_onWithdrawRequestStatusCleared);
  }

  final RestaurantRepo _repo;

  Future<void> _onRequested(
    PaymentDashboardRequested event,
    Emitter<PaymentDashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        status: PaymentDashboardStatus.loading,
        clearError: true,
        bankInfoStatus: PaymentDashboardStatus.loading,
        clearBankInfoError: true,
        payoutHistoryStatus: PaymentDashboardStatus.loading,
        payoutHistoryRows: const [],
        clearPayoutHistoryError: true,
        applyPayoutNextUrl: true,
        payoutNextUrl: null,
        payoutLoadingMore: false,
        withdrawRequestStatus: PaymentDashboardStatus.initial,
        clearWithdrawRequestMessage: true,
      ),
    );
    final allData = await _fetchAllData();
    final dashboardResult = allData.$1;
    final bankInfoResult = allData.$2;
    final payoutResult = allData.$3;

    emit(
      state.copyWith(
        status: dashboardResult.status,
        dashboard: dashboardResult.dashboard,
        errorMessage: dashboardResult.errorMessage,
        clearError: dashboardResult.errorMessage == null,
        bankInfoStatus: bankInfoResult.status,
        bankInfo: bankInfoResult.bankInfo,
        bankInfoErrorMessage: bankInfoResult.errorMessage,
        clearBankInfoError: bankInfoResult.errorMessage == null,
        payoutHistoryStatus: payoutResult.status,
        payoutHistoryRows: payoutResult.rows,
        payoutHistoryErrorMessage: payoutResult.errorMessage,
        clearPayoutHistoryError: payoutResult.errorMessage == null,
        applyPayoutNextUrl: true,
        payoutNextUrl: payoutResult.nextUrl,
      ),
    );
  }

  Future<void> _onPayoutHistoryLoadMore(
    PaymentPayoutHistoryLoadMore event,
    Emitter<PaymentDashboardState> emit,
  ) async {
    if (state.payoutNextUrl == null || state.payoutLoadingMore) return;
    emit(state.copyWith(payoutLoadingMore: true));
    try {
      final page = await _repo.getVendorPayoutRequests(
        url: state.payoutNextUrl,
      );
      final more = page.results.map(_mapRequestToRow).toList();
      emit(
        state.copyWith(
          payoutHistoryRows: [...state.payoutHistoryRows, ...more],
          applyPayoutNextUrl: true,
          payoutNextUrl: page.next,
          payoutLoadingMore: false,
        ),
      );
    } catch (e) {
      final ex = e is NetworkException ? e : null;
      emit(state.copyWith(payoutLoadingMore: false));
      getIt<Display>().error(
        ex?.message ?? TranslationKeys.paymentFailedLoadMore.tr(),
      );
    }
  }

  Future<void> _onWithdrawRequestSubmitted(
    PaymentWithdrawRequestSubmitted event,
    Emitter<PaymentDashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        withdrawRequestStatus: PaymentDashboardStatus.loading,
        clearWithdrawRequestMessage: true,
      ),
    );

    final normalized = _normalizeWithdrawAmount(event.requestedAmount);
    if (normalized == null) {
      emit(
        state.copyWith(
          withdrawRequestStatus: PaymentDashboardStatus.failure,
          withdrawRequestMessage: TranslationKeys.paymentEnterValidAmount.tr(),
        ),
      );
      return;
    }

    final amount = double.parse(normalized);
    if (amount > state.dashboard.currentBalance + 0.001) {
      emit(
        state.copyWith(
          withdrawRequestStatus: PaymentDashboardStatus.failure,
          withdrawRequestMessage: TranslationKeys.paymentExceedsBalance.tr(),
        ),
      );
      return;
    }

    try {
      await _repo.createVendorPayoutRequest(requestedAmount: normalized);
      final dashboard = await _repo.getVendorWalletDashboard();
      final payout = await _repo.getVendorPayoutRequests();
      final rows = payout.results.map(_mapRequestToRow).toList();
      emit(
        state.copyWith(
          dashboard: dashboard,
          payoutHistoryRows: rows,
          applyPayoutNextUrl: true,
          payoutNextUrl: payout.next,
          payoutHistoryStatus: PaymentDashboardStatus.success,
          clearPayoutHistoryError: true,
          withdrawRequestStatus: PaymentDashboardStatus.success,
          withdrawRequestMessage: TranslationKeys.paymentWithdrawRequestSent
              .tr(),
        ),
      );
    } catch (e) {
      final ex = e is NetworkException ? e : null;
      emit(
        state.copyWith(
          withdrawRequestStatus: PaymentDashboardStatus.failure,
          withdrawRequestMessage:
              ex?.message ?? TranslationKeys.paymentSubmitPayoutFailed.tr(),
        ),
      );
    }
  }

  void _onWithdrawRequestStatusCleared(
    PaymentWithdrawRequestStatusCleared event,
    Emitter<PaymentDashboardState> emit,
  ) {
    emit(
      state.copyWith(
        withdrawRequestStatus: PaymentDashboardStatus.initial,
        clearWithdrawRequestMessage: true,
      ),
    );
  }

  Future<_DashboardFetchResult> _fetchDashboardResult() async {
    try {
      final dashboard = await _repo.getVendorWalletDashboard();
      return _DashboardFetchResult(
        status: PaymentDashboardStatus.success,
        dashboard: dashboard,
      );
    } catch (e) {
      final ex = e is NetworkException ? e : null;
      return _DashboardFetchResult(
        status: PaymentDashboardStatus.failure,
        dashboard: state.dashboard,
        errorMessage:
            ex?.message ?? TranslationKeys.paymentFailedLoadDashboard.tr(),
      );
    }
  }

  Future<_BankInfoFetchResult> _fetchBankInfoResult() async {
    try {
      final bankInfo = await _repo.getVendorBankInfo();
      return _BankInfoFetchResult(
        status: PaymentDashboardStatus.success,
        bankInfo: bankInfo,
      );
    } catch (e) {
      final ex = e is NetworkException ? e : null;
      return _BankInfoFetchResult(
        status: PaymentDashboardStatus.failure,
        bankInfo: state.bankInfo,
        errorMessage:
            ex?.message ?? TranslationKeys.paymentFailedLoadBankInfo.tr(),
      );
    }
  }

  Future<_PayoutHistoryFetchResult> _fetchPayoutHistoryInitial() async {
    try {
      final page = await _repo.getVendorPayoutRequests();
      final rows = page.results.map(_mapRequestToRow).toList();
      return _PayoutHistoryFetchResult(
        status: PaymentDashboardStatus.success,
        rows: rows,
        nextUrl: page.next,
      );
    } catch (e) {
      final ex = e is NetworkException ? e : null;
      return _PayoutHistoryFetchResult(
        status: PaymentDashboardStatus.failure,
        rows: const [],
        nextUrl: null,
        errorMessage:
            ex?.message ?? TranslationKeys.paymentFailedLoadPayoutHistory.tr(),
      );
    }
  }

  Future<
    (_DashboardFetchResult, _BankInfoFetchResult, _PayoutHistoryFetchResult)
  >
  _fetchAllData() async {
    final results = await Future.wait([
      _fetchDashboardResult(),
      _fetchBankInfoResult(),
      _fetchPayoutHistoryInitial(),
    ]);
    return (
      results[0] as _DashboardFetchResult,
      results[1] as _BankInfoFetchResult,
      results[2] as _PayoutHistoryFetchResult,
    );
  }

  PaymentHistoryRowData _mapRequestToRow(VendorPayoutRequestModel r) {
    return PaymentHistoryRowData(
      '#${r.id}',
      _formatPayoutDate(r.createdAt),
      _mapPayoutStatusToBadge(r.status),
      _formatPayoutAmount(r.requestedAmount),
      statusLabel: r.statusDisplay.isNotEmpty ? r.statusDisplay : null,
    );
  }

  Future<void> _onBankInfoUpdateRequested(
    PaymentBankInfoUpdateRequested event,
    Emitter<PaymentDashboardState> emit,
  ) async {
    emit(
      state.copyWith(
        bankInfoUpdateStatus: PaymentDashboardStatus.loading,
        clearBankInfoUpdateMessage: true,
      ),
    );
    try {
      final updated = await _repo.updateVendorBankInfo(
        businessName: event.businessName,
        payoutSchedule: event.payoutSchedule,
        einNumber: event.einNumber,
        accountNumber: event.accountNumber,
        routingNumber: event.routingNumber,
      );
      emit(
        state.copyWith(
          bankInfoStatus: PaymentDashboardStatus.success,
          bankInfo: updated,
          clearBankInfoError: true,
          bankInfoUpdateStatus: PaymentDashboardStatus.success,
          bankInfoUpdateMessage: TranslationKeys.paymentBankAccountUpdated.tr(),
        ),
      );
    } catch (e) {
      final ex = e is NetworkException ? e : null;
      emit(
        state.copyWith(
          bankInfoUpdateStatus: PaymentDashboardStatus.failure,
          bankInfoUpdateMessage:
              ex?.message ?? TranslationKeys.paymentUpdateBankFailed.tr(),
        ),
      );
    }
  }

  void _onBankInfoUpdateStatusCleared(
    PaymentBankInfoUpdateStatusCleared event,
    Emitter<PaymentDashboardState> emit,
  ) {
    emit(
      state.copyWith(
        bankInfoUpdateStatus: PaymentDashboardStatus.initial,
        clearBankInfoUpdateMessage: true,
      ),
    );
  }
}

PaymentStatus _mapPayoutStatusToBadge(String raw) {
  switch (raw) {
    case 'completed':
      return PaymentStatus.verified;
    case 'rejected':
      return PaymentStatus.failed;
    case 'pending':
    case 'processing':
    default:
      return PaymentStatus.pending;
  }
}

String? _normalizeWithdrawAmount(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return null;
  final normalized = trimmed.replaceAll(',', '.');
  final v = double.tryParse(normalized);
  if (v == null || v <= 0) return null;
  return v.toStringAsFixed(2);
}

String _formatPayoutAmount(String raw) {
  final v = double.tryParse(raw.trim().replaceAll(',', '.'));
  if (v == null) {
    if (raw.trim().isEmpty) return '\$0.00';
    return raw.startsWith(r'$') ? raw : '\$$raw';
  }
  return '\$${v.toStringAsFixed(2)}';
}

String _formatPayoutDate(String iso) {
  if (iso.isEmpty) return '';
  try {
    final dt = DateTime.parse(iso).toLocal();
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final y = dt.year;
    var hour = dt.hour;
    final minute = dt.minute.toString().padLeft(2, '0');
    final isPm = hour >= 12;
    hour = hour % 12;
    if (hour == 0) hour = 12;
    final ampm = isPm ? 'PM' : 'AM';
    return '$d.$m.$y - $hour:$minute $ampm';
  } catch (_) {
    return iso;
  }
}

class _DashboardFetchResult {
  const _DashboardFetchResult({
    required this.status,
    required this.dashboard,
    this.errorMessage,
  });

  final PaymentDashboardStatus status;
  final VendorWalletDashboardModel dashboard;
  final String? errorMessage;
}

class _BankInfoFetchResult {
  const _BankInfoFetchResult({
    required this.status,
    required this.bankInfo,
    this.errorMessage,
  });

  final PaymentDashboardStatus status;
  final VendorBankInfoModel bankInfo;
  final String? errorMessage;
}

class _PayoutHistoryFetchResult {
  const _PayoutHistoryFetchResult({
    required this.status,
    required this.rows,
    this.nextUrl,
    this.errorMessage,
  });

  final PaymentDashboardStatus status;
  final List<PaymentHistoryRowData> rows;
  final String? nextUrl;
  final String? errorMessage;
}
