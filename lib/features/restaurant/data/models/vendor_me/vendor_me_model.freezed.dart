// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_me_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VendorMeModel {

 int? get id; String? get name; String? get description;@JsonKey(name: 'logo') String? get logo;@JsonKey(name: 'cover_image') String? get coverImage;@JsonKey(name: 'logo_url') String? get logoUrl;@JsonKey(name: 'cover_url') String? get coverUrl; String? get latitude; String? get longitude;@JsonKey(name: 'phone_number1') String? get phoneNumber1;@JsonKey(name: 'phone_number2') String? get phoneNumber2; String? get email; String? get address;@JsonKey(name: 'current_status') String? get currentStatus;@JsonKey(name: 'is_active') bool? get isActive;@JsonKey(name: 'rating_avg', fromJson: _ratingAvgFromJson) String? get ratingAvg;@JsonKey(fromJson: _categoriesFromJson) List<VendorCategoryItem> get categories;@JsonKey(name: 'workdays') List<VendorWorkdayMe> get workdays;@JsonKey(name: 'certificates') List<VendorCertificateMe> get certificates;@JsonKey(name: 'distance_km') double? get distanceKm;@JsonKey(name: 'distance_miles') double? get distanceMiles;@JsonKey(name: 'active_discount') Object? get activeDiscount;@JsonKey(name: 'avg_delivery_time') Object? get avgDeliveryTime;@JsonKey(name: 'created_at') String? get createdAt; int? get votes;
/// Create a copy of VendorMeModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorMeModelCopyWith<VendorMeModel> get copyWith => _$VendorMeModelCopyWithImpl<VendorMeModel>(this as VendorMeModel, _$identity);

  /// Serializes this VendorMeModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorMeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.logo, logo) || other.logo == logo)&&(identical(other.coverImage, coverImage) || other.coverImage == coverImage)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.phoneNumber1, phoneNumber1) || other.phoneNumber1 == phoneNumber1)&&(identical(other.phoneNumber2, phoneNumber2) || other.phoneNumber2 == phoneNumber2)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.currentStatus, currentStatus) || other.currentStatus == currentStatus)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.workdays, workdays)&&const DeepCollectionEquality().equals(other.certificates, certificates)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.distanceMiles, distanceMiles) || other.distanceMiles == distanceMiles)&&const DeepCollectionEquality().equals(other.activeDiscount, activeDiscount)&&const DeepCollectionEquality().equals(other.avgDeliveryTime, avgDeliveryTime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.votes, votes) || other.votes == votes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,logo,coverImage,logoUrl,coverUrl,latitude,longitude,phoneNumber1,phoneNumber2,email,address,currentStatus,isActive,ratingAvg,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(workdays),const DeepCollectionEquality().hash(certificates),distanceKm,distanceMiles,const DeepCollectionEquality().hash(activeDiscount),const DeepCollectionEquality().hash(avgDeliveryTime),createdAt,votes]);

@override
String toString() {
  return 'VendorMeModel(id: $id, name: $name, description: $description, logo: $logo, coverImage: $coverImage, logoUrl: $logoUrl, coverUrl: $coverUrl, latitude: $latitude, longitude: $longitude, phoneNumber1: $phoneNumber1, phoneNumber2: $phoneNumber2, email: $email, address: $address, currentStatus: $currentStatus, isActive: $isActive, ratingAvg: $ratingAvg, categories: $categories, workdays: $workdays, certificates: $certificates, distanceKm: $distanceKm, distanceMiles: $distanceMiles, activeDiscount: $activeDiscount, avgDeliveryTime: $avgDeliveryTime, createdAt: $createdAt, votes: $votes)';
}


}

/// @nodoc
abstract mixin class $VendorMeModelCopyWith<$Res>  {
  factory $VendorMeModelCopyWith(VendorMeModel value, $Res Function(VendorMeModel) _then) = _$VendorMeModelCopyWithImpl;
@useResult
$Res call({
 int? id, String? name, String? description,@JsonKey(name: 'logo') String? logo,@JsonKey(name: 'cover_image') String? coverImage,@JsonKey(name: 'logo_url') String? logoUrl,@JsonKey(name: 'cover_url') String? coverUrl, String? latitude, String? longitude,@JsonKey(name: 'phone_number1') String? phoneNumber1,@JsonKey(name: 'phone_number2') String? phoneNumber2, String? email, String? address,@JsonKey(name: 'current_status') String? currentStatus,@JsonKey(name: 'is_active') bool? isActive,@JsonKey(name: 'rating_avg', fromJson: _ratingAvgFromJson) String? ratingAvg,@JsonKey(fromJson: _categoriesFromJson) List<VendorCategoryItem> categories,@JsonKey(name: 'workdays') List<VendorWorkdayMe> workdays,@JsonKey(name: 'certificates') List<VendorCertificateMe> certificates,@JsonKey(name: 'distance_km') double? distanceKm,@JsonKey(name: 'distance_miles') double? distanceMiles,@JsonKey(name: 'active_discount') Object? activeDiscount,@JsonKey(name: 'avg_delivery_time') Object? avgDeliveryTime,@JsonKey(name: 'created_at') String? createdAt, int? votes
});




}
/// @nodoc
class _$VendorMeModelCopyWithImpl<$Res>
    implements $VendorMeModelCopyWith<$Res> {
  _$VendorMeModelCopyWithImpl(this._self, this._then);

  final VendorMeModel _self;
  final $Res Function(VendorMeModel) _then;

/// Create a copy of VendorMeModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,Object? description = freezed,Object? logo = freezed,Object? coverImage = freezed,Object? logoUrl = freezed,Object? coverUrl = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? phoneNumber1 = freezed,Object? phoneNumber2 = freezed,Object? email = freezed,Object? address = freezed,Object? currentStatus = freezed,Object? isActive = freezed,Object? ratingAvg = freezed,Object? categories = null,Object? workdays = null,Object? certificates = null,Object? distanceKm = freezed,Object? distanceMiles = freezed,Object? activeDiscount = freezed,Object? avgDeliveryTime = freezed,Object? createdAt = freezed,Object? votes = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,coverImage: freezed == coverImage ? _self.coverImage : coverImage // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber1: freezed == phoneNumber1 ? _self.phoneNumber1 : phoneNumber1 // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber2: freezed == phoneNumber2 ? _self.phoneNumber2 : phoneNumber2 // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,currentStatus: freezed == currentStatus ? _self.currentStatus : currentStatus // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,ratingAvg: freezed == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<VendorCategoryItem>,workdays: null == workdays ? _self.workdays : workdays // ignore: cast_nullable_to_non_nullable
as List<VendorWorkdayMe>,certificates: null == certificates ? _self.certificates : certificates // ignore: cast_nullable_to_non_nullable
as List<VendorCertificateMe>,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,distanceMiles: freezed == distanceMiles ? _self.distanceMiles : distanceMiles // ignore: cast_nullable_to_non_nullable
as double?,activeDiscount: freezed == activeDiscount ? _self.activeDiscount : activeDiscount ,avgDeliveryTime: freezed == avgDeliveryTime ? _self.avgDeliveryTime : avgDeliveryTime ,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,votes: freezed == votes ? _self.votes : votes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorMeModel].
extension VendorMeModelPatterns on VendorMeModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorMeModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorMeModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorMeModel value)  $default,){
final _that = this;
switch (_that) {
case _VendorMeModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorMeModel value)?  $default,){
final _that = this;
switch (_that) {
case _VendorMeModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? name,  String? description, @JsonKey(name: 'logo')  String? logo, @JsonKey(name: 'cover_image')  String? coverImage, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'cover_url')  String? coverUrl,  String? latitude,  String? longitude, @JsonKey(name: 'phone_number1')  String? phoneNumber1, @JsonKey(name: 'phone_number2')  String? phoneNumber2,  String? email,  String? address, @JsonKey(name: 'current_status')  String? currentStatus, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'rating_avg', fromJson: _ratingAvgFromJson)  String? ratingAvg, @JsonKey(fromJson: _categoriesFromJson)  List<VendorCategoryItem> categories, @JsonKey(name: 'workdays')  List<VendorWorkdayMe> workdays, @JsonKey(name: 'certificates')  List<VendorCertificateMe> certificates, @JsonKey(name: 'distance_km')  double? distanceKm, @JsonKey(name: 'distance_miles')  double? distanceMiles, @JsonKey(name: 'active_discount')  Object? activeDiscount, @JsonKey(name: 'avg_delivery_time')  Object? avgDeliveryTime, @JsonKey(name: 'created_at')  String? createdAt,  int? votes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorMeModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.logo,_that.coverImage,_that.logoUrl,_that.coverUrl,_that.latitude,_that.longitude,_that.phoneNumber1,_that.phoneNumber2,_that.email,_that.address,_that.currentStatus,_that.isActive,_that.ratingAvg,_that.categories,_that.workdays,_that.certificates,_that.distanceKm,_that.distanceMiles,_that.activeDiscount,_that.avgDeliveryTime,_that.createdAt,_that.votes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? name,  String? description, @JsonKey(name: 'logo')  String? logo, @JsonKey(name: 'cover_image')  String? coverImage, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'cover_url')  String? coverUrl,  String? latitude,  String? longitude, @JsonKey(name: 'phone_number1')  String? phoneNumber1, @JsonKey(name: 'phone_number2')  String? phoneNumber2,  String? email,  String? address, @JsonKey(name: 'current_status')  String? currentStatus, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'rating_avg', fromJson: _ratingAvgFromJson)  String? ratingAvg, @JsonKey(fromJson: _categoriesFromJson)  List<VendorCategoryItem> categories, @JsonKey(name: 'workdays')  List<VendorWorkdayMe> workdays, @JsonKey(name: 'certificates')  List<VendorCertificateMe> certificates, @JsonKey(name: 'distance_km')  double? distanceKm, @JsonKey(name: 'distance_miles')  double? distanceMiles, @JsonKey(name: 'active_discount')  Object? activeDiscount, @JsonKey(name: 'avg_delivery_time')  Object? avgDeliveryTime, @JsonKey(name: 'created_at')  String? createdAt,  int? votes)  $default,) {final _that = this;
switch (_that) {
case _VendorMeModel():
return $default(_that.id,_that.name,_that.description,_that.logo,_that.coverImage,_that.logoUrl,_that.coverUrl,_that.latitude,_that.longitude,_that.phoneNumber1,_that.phoneNumber2,_that.email,_that.address,_that.currentStatus,_that.isActive,_that.ratingAvg,_that.categories,_that.workdays,_that.certificates,_that.distanceKm,_that.distanceMiles,_that.activeDiscount,_that.avgDeliveryTime,_that.createdAt,_that.votes);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? name,  String? description, @JsonKey(name: 'logo')  String? logo, @JsonKey(name: 'cover_image')  String? coverImage, @JsonKey(name: 'logo_url')  String? logoUrl, @JsonKey(name: 'cover_url')  String? coverUrl,  String? latitude,  String? longitude, @JsonKey(name: 'phone_number1')  String? phoneNumber1, @JsonKey(name: 'phone_number2')  String? phoneNumber2,  String? email,  String? address, @JsonKey(name: 'current_status')  String? currentStatus, @JsonKey(name: 'is_active')  bool? isActive, @JsonKey(name: 'rating_avg', fromJson: _ratingAvgFromJson)  String? ratingAvg, @JsonKey(fromJson: _categoriesFromJson)  List<VendorCategoryItem> categories, @JsonKey(name: 'workdays')  List<VendorWorkdayMe> workdays, @JsonKey(name: 'certificates')  List<VendorCertificateMe> certificates, @JsonKey(name: 'distance_km')  double? distanceKm, @JsonKey(name: 'distance_miles')  double? distanceMiles, @JsonKey(name: 'active_discount')  Object? activeDiscount, @JsonKey(name: 'avg_delivery_time')  Object? avgDeliveryTime, @JsonKey(name: 'created_at')  String? createdAt,  int? votes)?  $default,) {final _that = this;
switch (_that) {
case _VendorMeModel() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.logo,_that.coverImage,_that.logoUrl,_that.coverUrl,_that.latitude,_that.longitude,_that.phoneNumber1,_that.phoneNumber2,_that.email,_that.address,_that.currentStatus,_that.isActive,_that.ratingAvg,_that.categories,_that.workdays,_that.certificates,_that.distanceKm,_that.distanceMiles,_that.activeDiscount,_that.avgDeliveryTime,_that.createdAt,_that.votes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorMeModel implements VendorMeModel {
  const _VendorMeModel({this.id, this.name, this.description, @JsonKey(name: 'logo') this.logo, @JsonKey(name: 'cover_image') this.coverImage, @JsonKey(name: 'logo_url') this.logoUrl, @JsonKey(name: 'cover_url') this.coverUrl, this.latitude, this.longitude, @JsonKey(name: 'phone_number1') this.phoneNumber1, @JsonKey(name: 'phone_number2') this.phoneNumber2, this.email, this.address, @JsonKey(name: 'current_status') this.currentStatus, @JsonKey(name: 'is_active') this.isActive, @JsonKey(name: 'rating_avg', fromJson: _ratingAvgFromJson) this.ratingAvg, @JsonKey(fromJson: _categoriesFromJson) final  List<VendorCategoryItem> categories = const [], @JsonKey(name: 'workdays') final  List<VendorWorkdayMe> workdays = const [], @JsonKey(name: 'certificates') final  List<VendorCertificateMe> certificates = const [], @JsonKey(name: 'distance_km') this.distanceKm, @JsonKey(name: 'distance_miles') this.distanceMiles, @JsonKey(name: 'active_discount') this.activeDiscount, @JsonKey(name: 'avg_delivery_time') this.avgDeliveryTime, @JsonKey(name: 'created_at') this.createdAt, this.votes}): _categories = categories,_workdays = workdays,_certificates = certificates;
  factory _VendorMeModel.fromJson(Map<String, dynamic> json) => _$VendorMeModelFromJson(json);

@override final  int? id;
@override final  String? name;
@override final  String? description;
@override@JsonKey(name: 'logo') final  String? logo;
@override@JsonKey(name: 'cover_image') final  String? coverImage;
@override@JsonKey(name: 'logo_url') final  String? logoUrl;
@override@JsonKey(name: 'cover_url') final  String? coverUrl;
@override final  String? latitude;
@override final  String? longitude;
@override@JsonKey(name: 'phone_number1') final  String? phoneNumber1;
@override@JsonKey(name: 'phone_number2') final  String? phoneNumber2;
@override final  String? email;
@override final  String? address;
@override@JsonKey(name: 'current_status') final  String? currentStatus;
@override@JsonKey(name: 'is_active') final  bool? isActive;
@override@JsonKey(name: 'rating_avg', fromJson: _ratingAvgFromJson) final  String? ratingAvg;
 final  List<VendorCategoryItem> _categories;
@override@JsonKey(fromJson: _categoriesFromJson) List<VendorCategoryItem> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<VendorWorkdayMe> _workdays;
@override@JsonKey(name: 'workdays') List<VendorWorkdayMe> get workdays {
  if (_workdays is EqualUnmodifiableListView) return _workdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_workdays);
}

 final  List<VendorCertificateMe> _certificates;
@override@JsonKey(name: 'certificates') List<VendorCertificateMe> get certificates {
  if (_certificates is EqualUnmodifiableListView) return _certificates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_certificates);
}

@override@JsonKey(name: 'distance_km') final  double? distanceKm;
@override@JsonKey(name: 'distance_miles') final  double? distanceMiles;
@override@JsonKey(name: 'active_discount') final  Object? activeDiscount;
@override@JsonKey(name: 'avg_delivery_time') final  Object? avgDeliveryTime;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override final  int? votes;

/// Create a copy of VendorMeModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorMeModelCopyWith<_VendorMeModel> get copyWith => __$VendorMeModelCopyWithImpl<_VendorMeModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorMeModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorMeModel&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.logo, logo) || other.logo == logo)&&(identical(other.coverImage, coverImage) || other.coverImage == coverImage)&&(identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl)&&(identical(other.coverUrl, coverUrl) || other.coverUrl == coverUrl)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.phoneNumber1, phoneNumber1) || other.phoneNumber1 == phoneNumber1)&&(identical(other.phoneNumber2, phoneNumber2) || other.phoneNumber2 == phoneNumber2)&&(identical(other.email, email) || other.email == email)&&(identical(other.address, address) || other.address == address)&&(identical(other.currentStatus, currentStatus) || other.currentStatus == currentStatus)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.ratingAvg, ratingAvg) || other.ratingAvg == ratingAvg)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._workdays, _workdays)&&const DeepCollectionEquality().equals(other._certificates, _certificates)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.distanceMiles, distanceMiles) || other.distanceMiles == distanceMiles)&&const DeepCollectionEquality().equals(other.activeDiscount, activeDiscount)&&const DeepCollectionEquality().equals(other.avgDeliveryTime, avgDeliveryTime)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.votes, votes) || other.votes == votes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,logo,coverImage,logoUrl,coverUrl,latitude,longitude,phoneNumber1,phoneNumber2,email,address,currentStatus,isActive,ratingAvg,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_workdays),const DeepCollectionEquality().hash(_certificates),distanceKm,distanceMiles,const DeepCollectionEquality().hash(activeDiscount),const DeepCollectionEquality().hash(avgDeliveryTime),createdAt,votes]);

@override
String toString() {
  return 'VendorMeModel(id: $id, name: $name, description: $description, logo: $logo, coverImage: $coverImage, logoUrl: $logoUrl, coverUrl: $coverUrl, latitude: $latitude, longitude: $longitude, phoneNumber1: $phoneNumber1, phoneNumber2: $phoneNumber2, email: $email, address: $address, currentStatus: $currentStatus, isActive: $isActive, ratingAvg: $ratingAvg, categories: $categories, workdays: $workdays, certificates: $certificates, distanceKm: $distanceKm, distanceMiles: $distanceMiles, activeDiscount: $activeDiscount, avgDeliveryTime: $avgDeliveryTime, createdAt: $createdAt, votes: $votes)';
}


}

/// @nodoc
abstract mixin class _$VendorMeModelCopyWith<$Res> implements $VendorMeModelCopyWith<$Res> {
  factory _$VendorMeModelCopyWith(_VendorMeModel value, $Res Function(_VendorMeModel) _then) = __$VendorMeModelCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? name, String? description,@JsonKey(name: 'logo') String? logo,@JsonKey(name: 'cover_image') String? coverImage,@JsonKey(name: 'logo_url') String? logoUrl,@JsonKey(name: 'cover_url') String? coverUrl, String? latitude, String? longitude,@JsonKey(name: 'phone_number1') String? phoneNumber1,@JsonKey(name: 'phone_number2') String? phoneNumber2, String? email, String? address,@JsonKey(name: 'current_status') String? currentStatus,@JsonKey(name: 'is_active') bool? isActive,@JsonKey(name: 'rating_avg', fromJson: _ratingAvgFromJson) String? ratingAvg,@JsonKey(fromJson: _categoriesFromJson) List<VendorCategoryItem> categories,@JsonKey(name: 'workdays') List<VendorWorkdayMe> workdays,@JsonKey(name: 'certificates') List<VendorCertificateMe> certificates,@JsonKey(name: 'distance_km') double? distanceKm,@JsonKey(name: 'distance_miles') double? distanceMiles,@JsonKey(name: 'active_discount') Object? activeDiscount,@JsonKey(name: 'avg_delivery_time') Object? avgDeliveryTime,@JsonKey(name: 'created_at') String? createdAt, int? votes
});




}
/// @nodoc
class __$VendorMeModelCopyWithImpl<$Res>
    implements _$VendorMeModelCopyWith<$Res> {
  __$VendorMeModelCopyWithImpl(this._self, this._then);

  final _VendorMeModel _self;
  final $Res Function(_VendorMeModel) _then;

/// Create a copy of VendorMeModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,Object? description = freezed,Object? logo = freezed,Object? coverImage = freezed,Object? logoUrl = freezed,Object? coverUrl = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? phoneNumber1 = freezed,Object? phoneNumber2 = freezed,Object? email = freezed,Object? address = freezed,Object? currentStatus = freezed,Object? isActive = freezed,Object? ratingAvg = freezed,Object? categories = null,Object? workdays = null,Object? certificates = null,Object? distanceKm = freezed,Object? distanceMiles = freezed,Object? activeDiscount = freezed,Object? avgDeliveryTime = freezed,Object? createdAt = freezed,Object? votes = freezed,}) {
  return _then(_VendorMeModel(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,coverImage: freezed == coverImage ? _self.coverImage : coverImage // ignore: cast_nullable_to_non_nullable
as String?,logoUrl: freezed == logoUrl ? _self.logoUrl : logoUrl // ignore: cast_nullable_to_non_nullable
as String?,coverUrl: freezed == coverUrl ? _self.coverUrl : coverUrl // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber1: freezed == phoneNumber1 ? _self.phoneNumber1 : phoneNumber1 // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber2: freezed == phoneNumber2 ? _self.phoneNumber2 : phoneNumber2 // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,currentStatus: freezed == currentStatus ? _self.currentStatus : currentStatus // ignore: cast_nullable_to_non_nullable
as String?,isActive: freezed == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool?,ratingAvg: freezed == ratingAvg ? _self.ratingAvg : ratingAvg // ignore: cast_nullable_to_non_nullable
as String?,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<VendorCategoryItem>,workdays: null == workdays ? _self._workdays : workdays // ignore: cast_nullable_to_non_nullable
as List<VendorWorkdayMe>,certificates: null == certificates ? _self._certificates : certificates // ignore: cast_nullable_to_non_nullable
as List<VendorCertificateMe>,distanceKm: freezed == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double?,distanceMiles: freezed == distanceMiles ? _self.distanceMiles : distanceMiles // ignore: cast_nullable_to_non_nullable
as double?,activeDiscount: freezed == activeDiscount ? _self.activeDiscount : activeDiscount ,avgDeliveryTime: freezed == avgDeliveryTime ? _self.avgDeliveryTime : avgDeliveryTime ,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,votes: freezed == votes ? _self.votes : votes // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$VendorCategoryItem {

 int? get id; String? get name;
/// Create a copy of VendorCategoryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorCategoryItemCopyWith<VendorCategoryItem> get copyWith => _$VendorCategoryItemCopyWithImpl<VendorCategoryItem>(this as VendorCategoryItem, _$identity);

  /// Serializes this VendorCategoryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorCategoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'VendorCategoryItem(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $VendorCategoryItemCopyWith<$Res>  {
  factory $VendorCategoryItemCopyWith(VendorCategoryItem value, $Res Function(VendorCategoryItem) _then) = _$VendorCategoryItemCopyWithImpl;
@useResult
$Res call({
 int? id, String? name
});




}
/// @nodoc
class _$VendorCategoryItemCopyWithImpl<$Res>
    implements $VendorCategoryItemCopyWith<$Res> {
  _$VendorCategoryItemCopyWithImpl(this._self, this._then);

  final VendorCategoryItem _self;
  final $Res Function(VendorCategoryItem) _then;

/// Create a copy of VendorCategoryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? name = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorCategoryItem].
extension VendorCategoryItemPatterns on VendorCategoryItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorCategoryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorCategoryItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorCategoryItem value)  $default,){
final _that = this;
switch (_that) {
case _VendorCategoryItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorCategoryItem value)?  $default,){
final _that = this;
switch (_that) {
case _VendorCategoryItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorCategoryItem() when $default != null:
return $default(_that.id,_that.name);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? name)  $default,) {final _that = this;
switch (_that) {
case _VendorCategoryItem():
return $default(_that.id,_that.name);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? name)?  $default,) {final _that = this;
switch (_that) {
case _VendorCategoryItem() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorCategoryItem implements VendorCategoryItem {
  const _VendorCategoryItem({this.id, this.name});
  factory _VendorCategoryItem.fromJson(Map<String, dynamic> json) => _$VendorCategoryItemFromJson(json);

@override final  int? id;
@override final  String? name;

/// Create a copy of VendorCategoryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorCategoryItemCopyWith<_VendorCategoryItem> get copyWith => __$VendorCategoryItemCopyWithImpl<_VendorCategoryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorCategoryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorCategoryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'VendorCategoryItem(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$VendorCategoryItemCopyWith<$Res> implements $VendorCategoryItemCopyWith<$Res> {
  factory _$VendorCategoryItemCopyWith(_VendorCategoryItem value, $Res Function(_VendorCategoryItem) _then) = __$VendorCategoryItemCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? name
});




}
/// @nodoc
class __$VendorCategoryItemCopyWithImpl<$Res>
    implements _$VendorCategoryItemCopyWith<$Res> {
  __$VendorCategoryItemCopyWithImpl(this._self, this._then);

  final _VendorCategoryItem _self;
  final $Res Function(_VendorCategoryItem) _then;

/// Create a copy of VendorCategoryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? name = freezed,}) {
  return _then(_VendorCategoryItem(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VendorWorkdayMe {

 String? get day;@JsonKey(name: 'from_time') String? get fromTime;@JsonKey(name: 'to_time') String? get toTime; String? get status;@JsonKey(name: 'current_status') String? get currentStatus;
/// Create a copy of VendorWorkdayMe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorWorkdayMeCopyWith<VendorWorkdayMe> get copyWith => _$VendorWorkdayMeCopyWithImpl<VendorWorkdayMe>(this as VendorWorkdayMe, _$identity);

  /// Serializes this VendorWorkdayMe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorWorkdayMe&&(identical(other.day, day) || other.day == day)&&(identical(other.fromTime, fromTime) || other.fromTime == fromTime)&&(identical(other.toTime, toTime) || other.toTime == toTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentStatus, currentStatus) || other.currentStatus == currentStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,fromTime,toTime,status,currentStatus);

@override
String toString() {
  return 'VendorWorkdayMe(day: $day, fromTime: $fromTime, toTime: $toTime, status: $status, currentStatus: $currentStatus)';
}


}

/// @nodoc
abstract mixin class $VendorWorkdayMeCopyWith<$Res>  {
  factory $VendorWorkdayMeCopyWith(VendorWorkdayMe value, $Res Function(VendorWorkdayMe) _then) = _$VendorWorkdayMeCopyWithImpl;
@useResult
$Res call({
 String? day,@JsonKey(name: 'from_time') String? fromTime,@JsonKey(name: 'to_time') String? toTime, String? status,@JsonKey(name: 'current_status') String? currentStatus
});




}
/// @nodoc
class _$VendorWorkdayMeCopyWithImpl<$Res>
    implements $VendorWorkdayMeCopyWith<$Res> {
  _$VendorWorkdayMeCopyWithImpl(this._self, this._then);

  final VendorWorkdayMe _self;
  final $Res Function(VendorWorkdayMe) _then;

/// Create a copy of VendorWorkdayMe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = freezed,Object? fromTime = freezed,Object? toTime = freezed,Object? status = freezed,Object? currentStatus = freezed,}) {
  return _then(_self.copyWith(
day: freezed == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String?,fromTime: freezed == fromTime ? _self.fromTime : fromTime // ignore: cast_nullable_to_non_nullable
as String?,toTime: freezed == toTime ? _self.toTime : toTime // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,currentStatus: freezed == currentStatus ? _self.currentStatus : currentStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorWorkdayMe].
extension VendorWorkdayMePatterns on VendorWorkdayMe {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorWorkdayMe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorWorkdayMe() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorWorkdayMe value)  $default,){
final _that = this;
switch (_that) {
case _VendorWorkdayMe():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorWorkdayMe value)?  $default,){
final _that = this;
switch (_that) {
case _VendorWorkdayMe() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? day, @JsonKey(name: 'from_time')  String? fromTime, @JsonKey(name: 'to_time')  String? toTime,  String? status, @JsonKey(name: 'current_status')  String? currentStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorWorkdayMe() when $default != null:
return $default(_that.day,_that.fromTime,_that.toTime,_that.status,_that.currentStatus);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? day, @JsonKey(name: 'from_time')  String? fromTime, @JsonKey(name: 'to_time')  String? toTime,  String? status, @JsonKey(name: 'current_status')  String? currentStatus)  $default,) {final _that = this;
switch (_that) {
case _VendorWorkdayMe():
return $default(_that.day,_that.fromTime,_that.toTime,_that.status,_that.currentStatus);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? day, @JsonKey(name: 'from_time')  String? fromTime, @JsonKey(name: 'to_time')  String? toTime,  String? status, @JsonKey(name: 'current_status')  String? currentStatus)?  $default,) {final _that = this;
switch (_that) {
case _VendorWorkdayMe() when $default != null:
return $default(_that.day,_that.fromTime,_that.toTime,_that.status,_that.currentStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorWorkdayMe implements VendorWorkdayMe {
  const _VendorWorkdayMe({this.day, @JsonKey(name: 'from_time') this.fromTime, @JsonKey(name: 'to_time') this.toTime, this.status, @JsonKey(name: 'current_status') this.currentStatus});
  factory _VendorWorkdayMe.fromJson(Map<String, dynamic> json) => _$VendorWorkdayMeFromJson(json);

@override final  String? day;
@override@JsonKey(name: 'from_time') final  String? fromTime;
@override@JsonKey(name: 'to_time') final  String? toTime;
@override final  String? status;
@override@JsonKey(name: 'current_status') final  String? currentStatus;

/// Create a copy of VendorWorkdayMe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorWorkdayMeCopyWith<_VendorWorkdayMe> get copyWith => __$VendorWorkdayMeCopyWithImpl<_VendorWorkdayMe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorWorkdayMeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorWorkdayMe&&(identical(other.day, day) || other.day == day)&&(identical(other.fromTime, fromTime) || other.fromTime == fromTime)&&(identical(other.toTime, toTime) || other.toTime == toTime)&&(identical(other.status, status) || other.status == status)&&(identical(other.currentStatus, currentStatus) || other.currentStatus == currentStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,fromTime,toTime,status,currentStatus);

@override
String toString() {
  return 'VendorWorkdayMe(day: $day, fromTime: $fromTime, toTime: $toTime, status: $status, currentStatus: $currentStatus)';
}


}

/// @nodoc
abstract mixin class _$VendorWorkdayMeCopyWith<$Res> implements $VendorWorkdayMeCopyWith<$Res> {
  factory _$VendorWorkdayMeCopyWith(_VendorWorkdayMe value, $Res Function(_VendorWorkdayMe) _then) = __$VendorWorkdayMeCopyWithImpl;
@override @useResult
$Res call({
 String? day,@JsonKey(name: 'from_time') String? fromTime,@JsonKey(name: 'to_time') String? toTime, String? status,@JsonKey(name: 'current_status') String? currentStatus
});




}
/// @nodoc
class __$VendorWorkdayMeCopyWithImpl<$Res>
    implements _$VendorWorkdayMeCopyWith<$Res> {
  __$VendorWorkdayMeCopyWithImpl(this._self, this._then);

  final _VendorWorkdayMe _self;
  final $Res Function(_VendorWorkdayMe) _then;

/// Create a copy of VendorWorkdayMe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = freezed,Object? fromTime = freezed,Object? toTime = freezed,Object? status = freezed,Object? currentStatus = freezed,}) {
  return _then(_VendorWorkdayMe(
day: freezed == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String?,fromTime: freezed == fromTime ? _self.fromTime : fromTime // ignore: cast_nullable_to_non_nullable
as String?,toTime: freezed == toTime ? _self.toTime : toTime // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,currentStatus: freezed == currentStatus ? _self.currentStatus : currentStatus // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$VendorCertificateMe {

 int? get id; String? get file; String? get status;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of VendorCertificateMe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorCertificateMeCopyWith<VendorCertificateMe> get copyWith => _$VendorCertificateMeCopyWithImpl<VendorCertificateMe>(this as VendorCertificateMe, _$identity);

  /// Serializes this VendorCertificateMe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorCertificateMe&&(identical(other.id, id) || other.id == id)&&(identical(other.file, file) || other.file == file)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,file,status,createdAt);

@override
String toString() {
  return 'VendorCertificateMe(id: $id, file: $file, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $VendorCertificateMeCopyWith<$Res>  {
  factory $VendorCertificateMeCopyWith(VendorCertificateMe value, $Res Function(VendorCertificateMe) _then) = _$VendorCertificateMeCopyWithImpl;
@useResult
$Res call({
 int? id, String? file, String? status,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$VendorCertificateMeCopyWithImpl<$Res>
    implements $VendorCertificateMeCopyWith<$Res> {
  _$VendorCertificateMeCopyWithImpl(this._self, this._then);

  final VendorCertificateMe _self;
  final $Res Function(VendorCertificateMe) _then;

/// Create a copy of VendorCertificateMe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? file = freezed,Object? status = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorCertificateMe].
extension VendorCertificateMePatterns on VendorCertificateMe {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorCertificateMe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorCertificateMe() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorCertificateMe value)  $default,){
final _that = this;
switch (_that) {
case _VendorCertificateMe():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorCertificateMe value)?  $default,){
final _that = this;
switch (_that) {
case _VendorCertificateMe() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? id,  String? file,  String? status, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorCertificateMe() when $default != null:
return $default(_that.id,_that.file,_that.status,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? id,  String? file,  String? status, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _VendorCertificateMe():
return $default(_that.id,_that.file,_that.status,_that.createdAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? id,  String? file,  String? status, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _VendorCertificateMe() when $default != null:
return $default(_that.id,_that.file,_that.status,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorCertificateMe implements VendorCertificateMe {
  const _VendorCertificateMe({this.id, this.file, this.status, @JsonKey(name: 'created_at') this.createdAt});
  factory _VendorCertificateMe.fromJson(Map<String, dynamic> json) => _$VendorCertificateMeFromJson(json);

@override final  int? id;
@override final  String? file;
@override final  String? status;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of VendorCertificateMe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorCertificateMeCopyWith<_VendorCertificateMe> get copyWith => __$VendorCertificateMeCopyWithImpl<_VendorCertificateMe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorCertificateMeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorCertificateMe&&(identical(other.id, id) || other.id == id)&&(identical(other.file, file) || other.file == file)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,file,status,createdAt);

@override
String toString() {
  return 'VendorCertificateMe(id: $id, file: $file, status: $status, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$VendorCertificateMeCopyWith<$Res> implements $VendorCertificateMeCopyWith<$Res> {
  factory _$VendorCertificateMeCopyWith(_VendorCertificateMe value, $Res Function(_VendorCertificateMe) _then) = __$VendorCertificateMeCopyWithImpl;
@override @useResult
$Res call({
 int? id, String? file, String? status,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$VendorCertificateMeCopyWithImpl<$Res>
    implements _$VendorCertificateMeCopyWith<$Res> {
  __$VendorCertificateMeCopyWithImpl(this._self, this._then);

  final _VendorCertificateMe _self;
  final $Res Function(_VendorCertificateMe) _then;

/// Create a copy of VendorCertificateMe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? file = freezed,Object? status = freezed,Object? createdAt = freezed,}) {
  return _then(_VendorCertificateMe(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,file: freezed == file ? _self.file : file // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
