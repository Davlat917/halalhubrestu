import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_bank_info/vendor_bank_info_model.dart';
import 'package:halalhub_restaurant/features/restaurant/data/models/vendor_wallet_dashboard/vendor_wallet_dashboard_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/payment/models/payment_history_row.dart';

enum PaymentDashboardStatus { initial, loading, success, failure }

class PaymentDashboardState extends Equatable {
  const PaymentDashboardState({
    this.status = PaymentDashboardStatus.initial,
    this.dashboard = const VendorWalletDashboardModel.empty(),
    this.errorMessage,
    this.bankInfoStatus = PaymentDashboardStatus.initial,
    this.bankInfo = const VendorBankInfoModel.empty(),
    this.bankInfoErrorMessage,
    this.bankInfoUpdateStatus = PaymentDashboardStatus.initial,
    this.bankInfoUpdateMessage,
    this.payoutHistoryStatus = PaymentDashboardStatus.initial,
    this.payoutHistoryRows = const [],
    this.payoutHistoryErrorMessage,
    this.payoutNextUrl,
    this.payoutLoadingMore = false,
    this.withdrawRequestStatus = PaymentDashboardStatus.initial,
    this.withdrawRequestMessage,
  });

  final PaymentDashboardStatus status;
  final VendorWalletDashboardModel dashboard;
  final String? errorMessage;
  final PaymentDashboardStatus bankInfoStatus;
  final VendorBankInfoModel bankInfo;
  final String? bankInfoErrorMessage;
  final PaymentDashboardStatus bankInfoUpdateStatus;
  final String? bankInfoUpdateMessage;
  final PaymentDashboardStatus payoutHistoryStatus;
  final List<PaymentHistoryRowData> payoutHistoryRows;
  final String? payoutHistoryErrorMessage;
  final String? payoutNextUrl;
  final bool payoutLoadingMore;
  final PaymentDashboardStatus withdrawRequestStatus;
  final String? withdrawRequestMessage;

  PaymentDashboardState copyWith({
    PaymentDashboardStatus? status,
    VendorWalletDashboardModel? dashboard,
    String? errorMessage,
    bool clearError = false,
    PaymentDashboardStatus? bankInfoStatus,
    VendorBankInfoModel? bankInfo,
    String? bankInfoErrorMessage,
    bool clearBankInfoError = false,
    PaymentDashboardStatus? bankInfoUpdateStatus,
    String? bankInfoUpdateMessage,
    bool clearBankInfoUpdateMessage = false,
    PaymentDashboardStatus? payoutHistoryStatus,
    List<PaymentHistoryRowData>? payoutHistoryRows,
    String? payoutHistoryErrorMessage,
    bool clearPayoutHistoryError = false,
    String? payoutNextUrl,
    /// `true` bo‘lsa [payoutNextUrl] qiymati (shu jumladan `null`) bevosita qo‘llanadi.
    bool applyPayoutNextUrl = false,
    bool? payoutLoadingMore,
    PaymentDashboardStatus? withdrawRequestStatus,
    String? withdrawRequestMessage,
    bool clearWithdrawRequestMessage = false,
  }) {
    return PaymentDashboardState(
      status: status ?? this.status,
      dashboard: dashboard ?? this.dashboard,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      bankInfoStatus: bankInfoStatus ?? this.bankInfoStatus,
      bankInfo: bankInfo ?? this.bankInfo,
      bankInfoErrorMessage: clearBankInfoError
          ? null
          : (bankInfoErrorMessage ?? this.bankInfoErrorMessage),
      bankInfoUpdateStatus: bankInfoUpdateStatus ?? this.bankInfoUpdateStatus,
      bankInfoUpdateMessage: clearBankInfoUpdateMessage
          ? null
          : (bankInfoUpdateMessage ?? this.bankInfoUpdateMessage),
      payoutHistoryStatus: payoutHistoryStatus ?? this.payoutHistoryStatus,
      payoutHistoryRows: payoutHistoryRows ?? this.payoutHistoryRows,
      payoutHistoryErrorMessage: clearPayoutHistoryError
          ? null
          : (payoutHistoryErrorMessage ?? this.payoutHistoryErrorMessage),
      payoutNextUrl: applyPayoutNextUrl ? payoutNextUrl : (payoutNextUrl ?? this.payoutNextUrl),
      payoutLoadingMore: payoutLoadingMore ?? this.payoutLoadingMore,
      withdrawRequestStatus: withdrawRequestStatus ?? this.withdrawRequestStatus,
      withdrawRequestMessage: clearWithdrawRequestMessage
          ? null
          : (withdrawRequestMessage ?? this.withdrawRequestMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        dashboard,
        errorMessage,
        bankInfoStatus,
        bankInfo,
        bankInfoErrorMessage,
        bankInfoUpdateStatus,
        bankInfoUpdateMessage,
        payoutHistoryStatus,
        payoutHistoryRows,
        payoutHistoryErrorMessage,
        payoutNextUrl,
        payoutLoadingMore,
        withdrawRequestStatus,
        withdrawRequestMessage,
      ];
}
