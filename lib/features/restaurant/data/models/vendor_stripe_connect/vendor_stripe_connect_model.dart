import 'package:equatable/equatable.dart';

class VendorStripeConnectModel extends Equatable {
  const VendorStripeConnectModel({
    required this.onboardingUrl,
    required this.message,
  });

  final String onboardingUrl;
  final String message;

  factory VendorStripeConnectModel.fromJson(Map<String, dynamic> json) {
    return VendorStripeConnectModel(
      onboardingUrl: json['onboarding_url'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [onboardingUrl, message];
}
