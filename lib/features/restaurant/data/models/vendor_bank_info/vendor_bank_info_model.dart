import 'package:equatable/equatable.dart';

class VendorBankInfoModel extends Equatable {
  const VendorBankInfoModel({
    required this.id,
    required this.businessName,
    required this.payoutSchedule,
    required this.einNumberMasked,
    required this.accountNumberMasked,
    required this.routingNumberMasked,
  });

  final int id;
  final String businessName;
  final String payoutSchedule;
  final String einNumberMasked;
  final String accountNumberMasked;
  final String routingNumberMasked;

  factory VendorBankInfoModel.fromJson(Map<String, dynamic> json) {
    return VendorBankInfoModel(
      id: json['id'] as int? ?? 0,
      businessName: json['business_name'] as String? ?? '',
      payoutSchedule: json['payout_schedule'] as String? ?? '',
      einNumberMasked: json['ein_number_masked'] as String? ?? '',
      accountNumberMasked: json['account_number_masked'] as String? ?? '',
      routingNumberMasked: json['routing_number_masked'] as String? ?? '',
    );
  }

  const VendorBankInfoModel.empty()
      : id = 0,
        businessName = '',
        payoutSchedule = '',
        einNumberMasked = '',
        accountNumberMasked = '',
        routingNumberMasked = '';

  @override
  List<Object?> get props => [
        id,
        businessName,
        payoutSchedule,
        einNumberMasked,
        accountNumberMasked,
        routingNumberMasked,
      ];
}
