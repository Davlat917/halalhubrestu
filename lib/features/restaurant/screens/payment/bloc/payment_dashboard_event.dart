import 'package:equatable/equatable.dart';

sealed class PaymentDashboardEvent extends Equatable {
  const PaymentDashboardEvent();

  @override
  List<Object?> get props => [];
}

final class PaymentDashboardRequested extends PaymentDashboardEvent {
  const PaymentDashboardRequested();
}

final class PaymentBankInfoUpdateRequested extends PaymentDashboardEvent {
  const PaymentBankInfoUpdateRequested({
    required this.businessName,
    required this.payoutSchedule,
    required this.einNumber,
    required this.accountNumber,
    required this.routingNumber,
  });

  final String businessName;
  final String payoutSchedule;
  final String einNumber;
  final String accountNumber;
  final String routingNumber;

  @override
  List<Object?> get props => [
        businessName,
        payoutSchedule,
        einNumber,
        accountNumber,
        routingNumber,
      ];
}

final class PaymentBankInfoUpdateStatusCleared extends PaymentDashboardEvent {
  const PaymentBankInfoUpdateStatusCleared();
}

final class PaymentPayoutHistoryLoadMore extends PaymentDashboardEvent {
  const PaymentPayoutHistoryLoadMore();
}

final class PaymentWithdrawRequestSubmitted extends PaymentDashboardEvent {
  const PaymentWithdrawRequestSubmitted({required this.requestedAmount});

  final String requestedAmount;

  @override
  List<Object?> get props => [requestedAmount];
}

final class PaymentWithdrawRequestStatusCleared extends PaymentDashboardEvent {
  const PaymentWithdrawRequestStatusCleared();
}
