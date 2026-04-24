import 'package:equatable/equatable.dart';

/// GET `/vendors/vendor/media/` — bitta clip yozuvi.
class VendorMediaClipModel extends Equatable {
  const VendorMediaClipModel({
    required this.id,
    required this.video,
    required this.description,
    this.vendorLogo,
    this.createdAt,
  });

  final int id;
  final String video;
  final String description;
  final String? vendorLogo;
  final String? createdAt;

  factory VendorMediaClipModel.fromJson(Map<String, dynamic> json) {
    return VendorMediaClipModel(
      id: json['id'] as int,
      video: json['video'] as String? ?? '',
      description: (json['description'] as String?)?.trim() ?? '',
      vendorLogo: json['vendor_logo'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, video, description, vendorLogo, createdAt];
}

/// Paginatsiya javobi.
class VendorMediaPageResult extends Equatable {
  const VendorMediaPageResult({
    required this.count,
    required this.results,
    this.next,
    this.previous,
  });

  final int count;
  final List<VendorMediaClipModel> results;
  final String? next;
  final String? previous;

  factory VendorMediaPageResult.fromJson(Map<String, dynamic> json) {
    final raw = json['results'];
    final list = <VendorMediaClipModel>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          list.add(VendorMediaClipModel.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    final nextVal = json['next'];
    final prevVal = json['previous'];
    return VendorMediaPageResult(
      count: json['count'] as int? ?? list.length,
      results: list,
      next: nextVal is String && nextVal.trim().isNotEmpty ? nextVal : null,
      previous: prevVal is String && prevVal.trim().isNotEmpty ? prevVal : null,
    );
  }

  @override
  List<Object?> get props => [count, results, next, previous];
}
