// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_create_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VendorCreateModel _$VendorCreateModelFromJson(Map<String, dynamic> json) =>
    _VendorCreateModel(
      name: json['name'] as String?,
      email: json['email'] as String?,
      phoneNumber1: json['phone_number1'] as String?,
      phoneNumber2: json['phone_number2'] as String?,
      description: json['description'] as String?,
      address: json['address'] as String?,
      latitude: json['latitude'] as String?,
      longitude: json['longitude'] as String?,
      certificateFiles: (json['certificate_files'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      workdays: (json['workdays'] as List<dynamic>?)
          ?.map((e) => Workday.fromJson(e as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
    );

Map<String, dynamic> _$VendorCreateModelToJson(_VendorCreateModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'email': instance.email,
      'phone_number1': instance.phoneNumber1,
      'phone_number2': instance.phoneNumber2,
      'description': instance.description,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'certificate_files': instance.certificateFiles,
      'workdays': instance.workdays,
      'categories': instance.categories,
    };

_Workday _$WorkdayFromJson(Map<String, dynamic> json) => _Workday(
  day: json['day'] as String?,
  fromTime: json['from_time'] as String?,
  toTime: json['to_time'] as String?,
  status: json['status'] as String?,
);

Map<String, dynamic> _$WorkdayToJson(_Workday instance) => <String, dynamic>{
  'day': instance.day,
  'from_time': instance.fromTime,
  'to_time': instance.toTime,
  'status': instance.status,
};
