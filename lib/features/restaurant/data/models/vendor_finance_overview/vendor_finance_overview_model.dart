import 'package:equatable/equatable.dart';

class VendorFinanceMetricModel extends Equatable {
  const VendorFinanceMetricModel({
    required this.amount,
    required this.change,
    required this.changePercent,
    required this.status,
  });

  final String amount;
  final String change;
  final String changePercent;
  final String status;

  factory VendorFinanceMetricModel.fromJson(Map<String, dynamic> json) {
    return VendorFinanceMetricModel(
      amount: json['amount'] as String? ?? '0.00',
      change: json['change'] as String? ?? '0.00',
      changePercent: json['change_percent'] as String? ?? '0.00',
      status: json['status'] as String? ?? 'same',
    );
  }

  const VendorFinanceMetricModel.empty()
      : amount = '0.00',
        change = '0.00',
        changePercent = '0.00',
        status = 'same';

  @override
  List<Object?> get props => [amount, change, changePercent, status];
}

class VendorFinanceOverviewModel extends Equatable {
  const VendorFinanceOverviewModel({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.yearly,
    this.currency,
  });

  final VendorFinanceMetricModel daily;
  final VendorFinanceMetricModel weekly;
  final VendorFinanceMetricModel monthly;
  final VendorFinanceMetricModel yearly;
  final String? currency;

  factory VendorFinanceOverviewModel.fromJson(Map<String, dynamic> json) {
    return VendorFinanceOverviewModel(
      daily: VendorFinanceMetricModel.fromJson(
        Map<String, dynamic>.from(json['daily'] as Map? ?? const {}),
      ),
      weekly: VendorFinanceMetricModel.fromJson(
        Map<String, dynamic>.from(json['weekly'] as Map? ?? const {}),
      ),
      monthly: VendorFinanceMetricModel.fromJson(
        Map<String, dynamic>.from(json['monthly'] as Map? ?? const {}),
      ),
      yearly: VendorFinanceMetricModel.fromJson(
        Map<String, dynamic>.from(json['yearly'] as Map? ?? const {}),
      ),
      currency: json['currency'] as String?,
    );
  }

  const VendorFinanceOverviewModel.empty()
      : daily = const VendorFinanceMetricModel.empty(),
        weekly = const VendorFinanceMetricModel.empty(),
        monthly = const VendorFinanceMetricModel.empty(),
        yearly = const VendorFinanceMetricModel.empty(),
        currency = null;

  @override
  List<Object?> get props => [daily, weekly, monthly, yearly, currency];
}
