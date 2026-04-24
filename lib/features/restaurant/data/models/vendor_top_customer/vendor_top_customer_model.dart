import 'package:equatable/equatable.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';

/// GET `/vendors/vendor/finance/top-customers/`
class VendorTopCustomerModel extends Equatable {
  const VendorTopCustomerModel({
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.avatar,
    required this.ordersCount,
    required this.totalSpent,
  });

  final int userId;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? avatar;
  final int ordersCount;
  final String totalSpent;

  factory VendorTopCustomerModel.fromJson(Map<String, dynamic> json) {
    final ordersRaw = json['orders_count'];
    return VendorTopCustomerModel(
      userId: json['user_id'] as int? ?? 0,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      avatar: json['avatar'] as String?,
      ordersCount: ordersRaw is int
          ? ordersRaw
          : int.tryParse(ordersRaw?.toString() ?? '') ?? 0,
      totalSpent: json['total_spent']?.toString() ?? '0.00',
    );
  }

  String get displayName {
    final name = '$firstName $lastName'.trim();
    if (name.isNotEmpty) return name;
    final phone = phoneNumber?.trim();
    if (phone != null && phone.isNotEmpty) return phone;
    return TranslationKeys.vendorDetailCustomerFallback.tr(
      namedArgs: {'id': '$userId'},
    );
  }

  @override
  List<Object?> get props => [
    userId,
    firstName,
    lastName,
    phoneNumber,
    avatar,
    ordersCount,
    totalSpent,
  ];
}
