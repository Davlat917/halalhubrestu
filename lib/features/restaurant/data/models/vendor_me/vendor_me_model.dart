import 'package:freezed_annotation/freezed_annotation.dart';

part 'vendor_me_model.freezed.dart';
part 'vendor_me_model.g.dart';

List<VendorCategoryItem> _categoriesFromJson(Object? json) {
  if (json == null) return [];
  if (json is! List<dynamic>) return [];
  final out = <VendorCategoryItem>[];
  for (final e in json) {
    if (e is int) {
      out.add(VendorCategoryItem(id: e));
    } else if (e is num) {
      out.add(VendorCategoryItem(id: e.toInt()));
    } else if (e is Map<String, dynamic>) {
      out.add(VendorCategoryItem.fromJson(e));
    }
  }
  return out;
}

String? _ratingAvgFromJson(Object? value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num) return value.toString();
  return value.toString();
}

@freezed
abstract class VendorMeModel with _$VendorMeModel {
  const factory VendorMeModel({
    int? id,
    String? name,
    String? description,
    @JsonKey(name: 'logo') String? logo,
    @JsonKey(name: 'cover_image') String? coverImage,
    @JsonKey(name: 'logo_url') String? logoUrl,
    @JsonKey(name: 'cover_url') String? coverUrl,
    String? latitude,
    String? longitude,
    @JsonKey(name: 'phone_number1') String? phoneNumber1,
    @JsonKey(name: 'phone_number2') String? phoneNumber2,
    String? email,
    String? address,
    @JsonKey(name: 'current_status') String? currentStatus,
    @JsonKey(name: 'is_active') bool? isActive,
    @JsonKey(name: 'rating_avg', fromJson: _ratingAvgFromJson)
    String? ratingAvg,
    @JsonKey(fromJson: _categoriesFromJson)
    @Default([])
    List<VendorCategoryItem> categories,
    @JsonKey(name: 'workdays') @Default([]) List<VendorWorkdayMe> workdays,
    @JsonKey(name: 'certificates')
    @Default([])
    List<VendorCertificateMe> certificates,
    @JsonKey(name: 'distance_km') double? distanceKm,
    @JsonKey(name: 'distance_miles') double? distanceMiles,
    @JsonKey(name: 'active_discount') Object? activeDiscount,
    @JsonKey(name: 'avg_delivery_time') Object? avgDeliveryTime,
    @JsonKey(name: 'created_at') String? createdAt,
    int? votes,
  }) = _VendorMeModel;

  factory VendorMeModel.fromJson(Map<String, dynamic> json) =>
      _$VendorMeModelFromJson(json);
}

@freezed
abstract class VendorCategoryItem with _$VendorCategoryItem {
  const factory VendorCategoryItem({int? id, String? name}) =
      _VendorCategoryItem;

  factory VendorCategoryItem.fromJson(Map<String, dynamic> json) =>
      _$VendorCategoryItemFromJson(json);
}

@freezed
abstract class VendorWorkdayMe with _$VendorWorkdayMe {
  const factory VendorWorkdayMe({
    String? day,
    @JsonKey(name: 'from_time') String? fromTime,
    @JsonKey(name: 'to_time') String? toTime,
    String? status,
    @JsonKey(name: 'current_status') String? currentStatus,
  }) = _VendorWorkdayMe;

  factory VendorWorkdayMe.fromJson(Map<String, dynamic> json) =>
      _$VendorWorkdayMeFromJson(json);
}

@freezed
abstract class VendorCertificateMe with _$VendorCertificateMe {
  const factory VendorCertificateMe({
    int? id,
    String? file,
    String? status,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _VendorCertificateMe;

  factory VendorCertificateMe.fromJson(Map<String, dynamic> json) =>
      _$VendorCertificateMeFromJson(json);
}
