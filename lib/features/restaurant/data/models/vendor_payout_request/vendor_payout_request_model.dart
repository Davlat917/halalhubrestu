import 'package:equatable/equatable.dart';

/// GET `/vendors/payout-requests/` — bitta yozuv.
class VendorPayoutRequestModel extends Equatable {
  const VendorPayoutRequestModel({
    required this.id,
    required this.requestedAmount,
    required this.status,
    required this.statusDisplay,
    this.adminNote,
    required this.createdAt,
    this.processedAt,
  });

  final int id;
  final String requestedAmount;
  final String status;
  final String statusDisplay;
  final String? adminNote;
  final String createdAt;
  final String? processedAt;

  factory VendorPayoutRequestModel.fromJson(Map<String, dynamic> json) {
    return VendorPayoutRequestModel(
      id: json['id'] as int,
      requestedAmount: json['requested_amount'] as String? ?? '',
      status: json['status'] as String? ?? '',
      statusDisplay: json['status_display'] as String? ?? '',
      adminNote: json['admin_note'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      processedAt: json['processed_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [
        id,
        requestedAmount,
        status,
        statusDisplay,
        adminNote,
        createdAt,
        processedAt,
      ];
}

/// Paginatsiya javobi.
class VendorPayoutRequestsPageResult extends Equatable {
  const VendorPayoutRequestsPageResult({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final List<VendorPayoutRequestModel> results;
  final String? next;
  final String? previous;

  factory VendorPayoutRequestsPageResult.fromJson(Map<String, dynamic> json) {
    final raw = json['results'];
    final list = <VendorPayoutRequestModel>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          list.add(
            VendorPayoutRequestModel.fromJson(Map<String, dynamic>.from(e)),
          );
        }
      }
    }
    final nextVal = json['next'];
    final prevVal = json['previous'];
    return VendorPayoutRequestsPageResult(
      count: json['count'] as int? ?? list.length,
      results: list,
      next: nextVal is String && nextVal.trim().isNotEmpty ? nextVal : null,
      previous: prevVal is String && prevVal.trim().isNotEmpty ? prevVal : null,
    );
  }

  @override
  List<Object?> get props => [count, results, next, previous];
}
