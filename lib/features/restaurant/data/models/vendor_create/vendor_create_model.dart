// To parse this JSON data, do
//
//     final vendorCreateModel = vendorCreateModelFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'vendor_create_model.freezed.dart';
part 'vendor_create_model.g.dart';

VendorCreateModel vendorCreateModelFromJson(String str) =>
    VendorCreateModel.fromJson(json.decode(str));

String vendorCreateModelToJson(VendorCreateModel data) =>
    json.encode(data.toJson());

@freezed
abstract class VendorCreateModel with _$VendorCreateModel {
  const factory VendorCreateModel({
    @JsonKey(name: "name") String? name,
    @JsonKey(name: "email") String? email,
    @JsonKey(name: "phone_number1") String? phoneNumber1,
    @JsonKey(name: "phone_number2") String? phoneNumber2,
    @JsonKey(name: "description") String? description,
    @JsonKey(name: "address") String? address,
    @JsonKey(name: "latitude") String? latitude,
    @JsonKey(name: "longitude") String? longitude,
    @JsonKey(name: "certificate_files") List<String>? certificateFiles,
    @JsonKey(name: "workdays") List<Workday>? workdays,
    @JsonKey(name: "categories") List<int>? categories, //
  }) = _VendorCreateModel;

  factory VendorCreateModel.fromJson(Map<String, dynamic> json) =>
      _$VendorCreateModelFromJson(json);
}

@freezed
abstract class Workday with _$Workday {
  const factory Workday({
    @JsonKey(name: "day") String? day,
    @JsonKey(name: "from_time") String? fromTime,
    @JsonKey(name: "to_time") String? toTime,
    @JsonKey(name: "status") String? status, //
  }) = _Workday;

  factory Workday.fromJson(Map<String, dynamic> json) =>
      _$WorkdayFromJson(json);
}
