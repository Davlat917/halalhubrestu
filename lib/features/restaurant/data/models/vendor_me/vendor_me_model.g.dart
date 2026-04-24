// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_me_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VendorMeModel _$VendorMeModelFromJson(Map<String, dynamic> json) =>
    _VendorMeModel(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      description: json['description'] as String?,
      logo: json['logo'] as String?,
      coverImage: json['cover_image'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverUrl: json['cover_url'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      phoneNumber1: json['phone_number1'] as String?,
      phoneNumber2: json['phone_number2'] as String?,
      email: json['email'] as String?,
      address: json['address'] as String?,
      currentStatus: json['current_status'] as String?,
      isActive: json['is_active'] as bool?,
      ratingAvg: _ratingAvgFromJson(json['rating_avg']),
      categories: json['categories'] == null
          ? const []
          : _categoriesFromJson(json['categories']),
      workdays:
          (json['workdays'] as List<dynamic>?)
              ?.map((e) => VendorWorkdayMe.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      certificates:
          (json['certificates'] as List<dynamic>?)
              ?.map(
                (e) => VendorCertificateMe.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          const [],
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      distanceMiles: (json['distance_miles'] as num?)?.toDouble(),
      activeDiscount: json['active_discount'],
      avgDeliveryTime: json['avg_delivery_time'],
      createdAt: json['created_at'] as String?,
      votes: (json['votes'] as num?)?.toInt(),
    );

Map<String, dynamic> _$VendorMeModelToJson(_VendorMeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'logo': instance.logo,
      'cover_image': instance.coverImage,
      'logo_url': instance.logoUrl,
      'cover_url': instance.coverUrl,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'phone_number1': instance.phoneNumber1,
      'phone_number2': instance.phoneNumber2,
      'email': instance.email,
      'address': instance.address,
      'current_status': instance.currentStatus,
      'is_active': instance.isActive,
      'rating_avg': instance.ratingAvg,
      'categories': instance.categories,
      'workdays': instance.workdays,
      'certificates': instance.certificates,
      'distance_km': instance.distanceKm,
      'distance_miles': instance.distanceMiles,
      'active_discount': instance.activeDiscount,
      'avg_delivery_time': instance.avgDeliveryTime,
      'created_at': instance.createdAt,
      'votes': instance.votes,
    };

_VendorCategoryItem _$VendorCategoryItemFromJson(Map<String, dynamic> json) =>
    _VendorCategoryItem(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
    );

Map<String, dynamic> _$VendorCategoryItemToJson(_VendorCategoryItem instance) =>
    <String, dynamic>{'id': instance.id, 'name': instance.name};

_VendorWorkdayMe _$VendorWorkdayMeFromJson(Map<String, dynamic> json) =>
    _VendorWorkdayMe(
      day: json['day'] as String?,
      fromTime: json['from_time'] as String?,
      toTime: json['to_time'] as String?,
      status: json['status'] as String?,
      currentStatus: json['current_status'] as String?,
    );

Map<String, dynamic> _$VendorWorkdayMeToJson(_VendorWorkdayMe instance) =>
    <String, dynamic>{
      'day': instance.day,
      'from_time': instance.fromTime,
      'to_time': instance.toTime,
      'status': instance.status,
      'current_status': instance.currentStatus,
    };

_VendorCertificateMe _$VendorCertificateMeFromJson(Map<String, dynamic> json) =>
    _VendorCertificateMe(
      id: (json['id'] as num?)?.toInt(),
      file: json['file'] as String?,
      status: json['status'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$VendorCertificateMeToJson(
  _VendorCertificateMe instance,
) => <String, dynamic>{
  'id': instance.id,
  'file': instance.file,
  'status': instance.status,
  'created_at': instance.createdAt,
};
