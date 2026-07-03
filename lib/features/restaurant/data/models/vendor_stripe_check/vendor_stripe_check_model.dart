import 'package:equatable/equatable.dart';

class VendorStripeCheckModel extends Equatable {
  const VendorStripeCheckModel({
    required this.isConnected,
    required this.chargesEnabled,
    required this.requirements,
    this.detailsMessage,
  });

  final bool isConnected;
  final bool chargesEnabled;
  final List<String> requirements;
  final String? detailsMessage;

  factory VendorStripeCheckModel.fromJson(Map<String, dynamic> json) {
    final requirementsRaw = json['requirements'];
    final requirements = <String>[];
    if (requirementsRaw is List) {
      for (final item in requirementsRaw) {
        final value = item?.toString().trim();
        if (value != null && value.isNotEmpty) requirements.add(value);
      }
    }

    return VendorStripeCheckModel(
      isConnected: json['is_connected'] as bool? ?? false,
      chargesEnabled: json['charges_enabled'] as bool? ?? false,
      requirements: requirements,
      detailsMessage: _parseDetailsMessage(json['details']),
    );
  }

  const VendorStripeCheckModel.empty()
      : isConnected = false,
        chargesEnabled = false,
        requirements = const [],
        detailsMessage = null;

  bool get isFullyReady => isConnected && chargesEnabled && requirements.isEmpty;

  static String? _parseDetailsMessage(dynamic value) {
    if (value is String) {
      final text = value.trim();
      return text.isEmpty ? null : text;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        isConnected,
        chargesEnabled,
        requirements,
        detailsMessage,
      ];
}
