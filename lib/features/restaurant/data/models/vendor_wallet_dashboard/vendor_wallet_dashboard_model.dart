import 'package:equatable/equatable.dart';

class VendorWalletDashboardModel extends Equatable {
  const VendorWalletDashboardModel({
    required this.currentBalance,
    required this.availableForWithdrawal,
    required this.totalEarned,
    required this.totalPlatformDebt,
    required this.pendingPayoutsSum,
  });

  final double currentBalance;
  final double availableForWithdrawal;
  final double totalEarned;
  final double totalPlatformDebt;
  final double pendingPayoutsSum;

  factory VendorWalletDashboardModel.fromJson(Map<String, dynamic> json) {
    double toDouble(dynamic value) =>
        value is num ? value.toDouble() : double.tryParse('$value') ?? 0;

    return VendorWalletDashboardModel(
      currentBalance: toDouble(json['current_balance']),
      availableForWithdrawal: toDouble(json['available_for_withdrawal']),
      totalEarned: toDouble(json['total_earned']),
      totalPlatformDebt: toDouble(json['total_platform_debt']),
      pendingPayoutsSum: toDouble(json['pending_payouts_sum']),
    );
  }

  const VendorWalletDashboardModel.empty()
      : currentBalance = 0,
        availableForWithdrawal = 0,
        totalEarned = 0,
        totalPlatformDebt = 0,
        pendingPayoutsSum = 0;

  @override
  List<Object?> get props => [
        currentBalance,
        availableForWithdrawal,
        totalEarned,
        totalPlatformDebt,
        pendingPayoutsSum,
      ];
}
