import 'package:equatable/equatable.dart';

/// POST `/delivery/clover/connect/` javabi.
class CloverConnectResponse extends Equatable {
  const CloverConnectResponse({
    required this.vendorId,
    required this.authorizeUrl,
  });

  final int vendorId;
  final String authorizeUrl;

  factory CloverConnectResponse.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> root = json;
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      root = data;
    } else if (data is Map) {
      root = Map<String, dynamic>.from(data);
    }
    return CloverConnectResponse(
      vendorId: (root['vendor_id'] as num?)?.toInt() ?? 0,
      authorizeUrl: (root['authorize_url']?.toString() ?? '').trim(),
    );
  }

  @override
  List<Object?> get props => [vendorId, authorizeUrl];
}
