import 'package:equatable/equatable.dart';

/// GET `/delivery/vendor/pos/providers/` javabi.
class VendorPosProvidersResponse extends Equatable {
  const VendorPosProvidersResponse({
    required this.vendorId,
    required this.vendorName,
    required this.activeProvider,
    required this.providers,
  });

  final int vendorId;
  final String vendorName;
  final String activeProvider;
  final List<VendorPosProviderItem> providers;

  factory VendorPosProvidersResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['providers'];
    final list = <VendorPosProviderItem>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map<String, dynamic>) {
          list.add(VendorPosProviderItem.fromJson(e));
        } else if (e is Map) {
          list.add(VendorPosProviderItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    return VendorPosProvidersResponse(
      vendorId: (json['vendor_id'] as num?)?.toInt() ?? 0,
      vendorName: json['vendor_name']?.toString() ?? '',
      activeProvider: (json['active_provider']?.toString() ?? '').trim().toLowerCase(),
      providers: list,
    );
  }

  VendorPosProvidersResponse copyWith({
    int? vendorId,
    String? vendorName,
    String? activeProvider,
    List<VendorPosProviderItem>? providers,
  }) {
    return VendorPosProvidersResponse(
      vendorId: vendorId ?? this.vendorId,
      vendorName: vendorName ?? this.vendorName,
      activeProvider: activeProvider ?? this.activeProvider,
      providers: providers ?? this.providers,
    );
  }

  @override
  List<Object?> get props => [vendorId, vendorName, activeProvider, providers];
}

class VendorPosProviderItem extends Equatable {
  const VendorPosProviderItem({
    required this.provider,
    required this.label,
    required this.connected,
    required this.active,
    required this.missingFields,
  });

  final String provider;
  final String label;
  final bool connected;
  final bool active;
  final List<String> missingFields;

  String get providerId => provider.trim().toLowerCase();

  bool get isSelectable => connected && missingFields.isEmpty;

  factory VendorPosProviderItem.fromJson(Map<String, dynamic> json) {
    final missing = json['missing_fields'];
    final fields = <String>[];
    if (missing is List) {
      for (final e in missing) {
        final s = e?.toString().trim();
        if (s != null && s.isNotEmpty) fields.add(s);
      }
    }
    return VendorPosProviderItem(
      provider: (json['provider']?.toString() ?? '').trim().toLowerCase(),
      label: json['label']?.toString() ?? '',
      connected: json['connected'] == true,
      active: json['active'] == true,
      missingFields: fields,
    );
  }

  VendorPosProviderItem copyWith({
    String? provider,
    String? label,
    bool? connected,
    bool? active,
    List<String>? missingFields,
  }) {
    return VendorPosProviderItem(
      provider: provider ?? this.provider,
      label: label ?? this.label,
      connected: connected ?? this.connected,
      active: active ?? this.active,
      missingFields: missingFields ?? this.missingFields,
    );
  }

  @override
  List<Object?> get props => [provider, label, connected, active, missingFields];
}
