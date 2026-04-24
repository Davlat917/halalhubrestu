// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vendor_create_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VendorCreateModel {

@JsonKey(name: "name") String? get name;@JsonKey(name: "email") String? get email;@JsonKey(name: "phone_number1") String? get phoneNumber1;@JsonKey(name: "phone_number2") String? get phoneNumber2;@JsonKey(name: "description") String? get description;@JsonKey(name: "address") String? get address;@JsonKey(name: "latitude") String? get latitude;@JsonKey(name: "longitude") String? get longitude;@JsonKey(name: "certificate_files") List<String>? get certificateFiles;@JsonKey(name: "workdays") List<Workday>? get workdays;@JsonKey(name: "categories") List<int>? get categories;
/// Create a copy of VendorCreateModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VendorCreateModelCopyWith<VendorCreateModel> get copyWith => _$VendorCreateModelCopyWithImpl<VendorCreateModel>(this as VendorCreateModel, _$identity);

  /// Serializes this VendorCreateModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VendorCreateModel&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber1, phoneNumber1) || other.phoneNumber1 == phoneNumber1)&&(identical(other.phoneNumber2, phoneNumber2) || other.phoneNumber2 == phoneNumber2)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.certificateFiles, certificateFiles)&&const DeepCollectionEquality().equals(other.workdays, workdays)&&const DeepCollectionEquality().equals(other.categories, categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,phoneNumber1,phoneNumber2,description,address,latitude,longitude,const DeepCollectionEquality().hash(certificateFiles),const DeepCollectionEquality().hash(workdays),const DeepCollectionEquality().hash(categories));

@override
String toString() {
  return 'VendorCreateModel(name: $name, email: $email, phoneNumber1: $phoneNumber1, phoneNumber2: $phoneNumber2, description: $description, address: $address, latitude: $latitude, longitude: $longitude, certificateFiles: $certificateFiles, workdays: $workdays, categories: $categories)';
}


}

/// @nodoc
abstract mixin class $VendorCreateModelCopyWith<$Res>  {
  factory $VendorCreateModelCopyWith(VendorCreateModel value, $Res Function(VendorCreateModel) _then) = _$VendorCreateModelCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "name") String? name,@JsonKey(name: "email") String? email,@JsonKey(name: "phone_number1") String? phoneNumber1,@JsonKey(name: "phone_number2") String? phoneNumber2,@JsonKey(name: "description") String? description,@JsonKey(name: "address") String? address,@JsonKey(name: "latitude") String? latitude,@JsonKey(name: "longitude") String? longitude,@JsonKey(name: "certificate_files") List<String>? certificateFiles,@JsonKey(name: "workdays") List<Workday>? workdays,@JsonKey(name: "categories") List<int>? categories
});




}
/// @nodoc
class _$VendorCreateModelCopyWithImpl<$Res>
    implements $VendorCreateModelCopyWith<$Res> {
  _$VendorCreateModelCopyWithImpl(this._self, this._then);

  final VendorCreateModel _self;
  final $Res Function(VendorCreateModel) _then;

/// Create a copy of VendorCreateModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? email = freezed,Object? phoneNumber1 = freezed,Object? phoneNumber2 = freezed,Object? description = freezed,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? certificateFiles = freezed,Object? workdays = freezed,Object? categories = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber1: freezed == phoneNumber1 ? _self.phoneNumber1 : phoneNumber1 // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber2: freezed == phoneNumber2 ? _self.phoneNumber2 : phoneNumber2 // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,certificateFiles: freezed == certificateFiles ? _self.certificateFiles : certificateFiles // ignore: cast_nullable_to_non_nullable
as List<String>?,workdays: freezed == workdays ? _self.workdays : workdays // ignore: cast_nullable_to_non_nullable
as List<Workday>?,categories: freezed == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<int>?,
  ));
}

}


/// Adds pattern-matching-related methods to [VendorCreateModel].
extension VendorCreateModelPatterns on VendorCreateModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VendorCreateModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VendorCreateModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VendorCreateModel value)  $default,){
final _that = this;
switch (_that) {
case _VendorCreateModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VendorCreateModel value)?  $default,){
final _that = this;
switch (_that) {
case _VendorCreateModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: "name")  String? name, @JsonKey(name: "email")  String? email, @JsonKey(name: "phone_number1")  String? phoneNumber1, @JsonKey(name: "phone_number2")  String? phoneNumber2, @JsonKey(name: "description")  String? description, @JsonKey(name: "address")  String? address, @JsonKey(name: "latitude")  String? latitude, @JsonKey(name: "longitude")  String? longitude, @JsonKey(name: "certificate_files")  List<String>? certificateFiles, @JsonKey(name: "workdays")  List<Workday>? workdays, @JsonKey(name: "categories")  List<int>? categories)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VendorCreateModel() when $default != null:
return $default(_that.name,_that.email,_that.phoneNumber1,_that.phoneNumber2,_that.description,_that.address,_that.latitude,_that.longitude,_that.certificateFiles,_that.workdays,_that.categories);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: "name")  String? name, @JsonKey(name: "email")  String? email, @JsonKey(name: "phone_number1")  String? phoneNumber1, @JsonKey(name: "phone_number2")  String? phoneNumber2, @JsonKey(name: "description")  String? description, @JsonKey(name: "address")  String? address, @JsonKey(name: "latitude")  String? latitude, @JsonKey(name: "longitude")  String? longitude, @JsonKey(name: "certificate_files")  List<String>? certificateFiles, @JsonKey(name: "workdays")  List<Workday>? workdays, @JsonKey(name: "categories")  List<int>? categories)  $default,) {final _that = this;
switch (_that) {
case _VendorCreateModel():
return $default(_that.name,_that.email,_that.phoneNumber1,_that.phoneNumber2,_that.description,_that.address,_that.latitude,_that.longitude,_that.certificateFiles,_that.workdays,_that.categories);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: "name")  String? name, @JsonKey(name: "email")  String? email, @JsonKey(name: "phone_number1")  String? phoneNumber1, @JsonKey(name: "phone_number2")  String? phoneNumber2, @JsonKey(name: "description")  String? description, @JsonKey(name: "address")  String? address, @JsonKey(name: "latitude")  String? latitude, @JsonKey(name: "longitude")  String? longitude, @JsonKey(name: "certificate_files")  List<String>? certificateFiles, @JsonKey(name: "workdays")  List<Workday>? workdays, @JsonKey(name: "categories")  List<int>? categories)?  $default,) {final _that = this;
switch (_that) {
case _VendorCreateModel() when $default != null:
return $default(_that.name,_that.email,_that.phoneNumber1,_that.phoneNumber2,_that.description,_that.address,_that.latitude,_that.longitude,_that.certificateFiles,_that.workdays,_that.categories);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VendorCreateModel implements VendorCreateModel {
  const _VendorCreateModel({@JsonKey(name: "name") this.name, @JsonKey(name: "email") this.email, @JsonKey(name: "phone_number1") this.phoneNumber1, @JsonKey(name: "phone_number2") this.phoneNumber2, @JsonKey(name: "description") this.description, @JsonKey(name: "address") this.address, @JsonKey(name: "latitude") this.latitude, @JsonKey(name: "longitude") this.longitude, @JsonKey(name: "certificate_files") final  List<String>? certificateFiles, @JsonKey(name: "workdays") final  List<Workday>? workdays, @JsonKey(name: "categories") final  List<int>? categories}): _certificateFiles = certificateFiles,_workdays = workdays,_categories = categories;
  factory _VendorCreateModel.fromJson(Map<String, dynamic> json) => _$VendorCreateModelFromJson(json);

@override@JsonKey(name: "name") final  String? name;
@override@JsonKey(name: "email") final  String? email;
@override@JsonKey(name: "phone_number1") final  String? phoneNumber1;
@override@JsonKey(name: "phone_number2") final  String? phoneNumber2;
@override@JsonKey(name: "description") final  String? description;
@override@JsonKey(name: "address") final  String? address;
@override@JsonKey(name: "latitude") final  String? latitude;
@override@JsonKey(name: "longitude") final  String? longitude;
 final  List<String>? _certificateFiles;
@override@JsonKey(name: "certificate_files") List<String>? get certificateFiles {
  final value = _certificateFiles;
  if (value == null) return null;
  if (_certificateFiles is EqualUnmodifiableListView) return _certificateFiles;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<Workday>? _workdays;
@override@JsonKey(name: "workdays") List<Workday>? get workdays {
  final value = _workdays;
  if (value == null) return null;
  if (_workdays is EqualUnmodifiableListView) return _workdays;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<int>? _categories;
@override@JsonKey(name: "categories") List<int>? get categories {
  final value = _categories;
  if (value == null) return null;
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of VendorCreateModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VendorCreateModelCopyWith<_VendorCreateModel> get copyWith => __$VendorCreateModelCopyWithImpl<_VendorCreateModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VendorCreateModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VendorCreateModel&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber1, phoneNumber1) || other.phoneNumber1 == phoneNumber1)&&(identical(other.phoneNumber2, phoneNumber2) || other.phoneNumber2 == phoneNumber2)&&(identical(other.description, description) || other.description == description)&&(identical(other.address, address) || other.address == address)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._certificateFiles, _certificateFiles)&&const DeepCollectionEquality().equals(other._workdays, _workdays)&&const DeepCollectionEquality().equals(other._categories, _categories));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,email,phoneNumber1,phoneNumber2,description,address,latitude,longitude,const DeepCollectionEquality().hash(_certificateFiles),const DeepCollectionEquality().hash(_workdays),const DeepCollectionEquality().hash(_categories));

@override
String toString() {
  return 'VendorCreateModel(name: $name, email: $email, phoneNumber1: $phoneNumber1, phoneNumber2: $phoneNumber2, description: $description, address: $address, latitude: $latitude, longitude: $longitude, certificateFiles: $certificateFiles, workdays: $workdays, categories: $categories)';
}


}

/// @nodoc
abstract mixin class _$VendorCreateModelCopyWith<$Res> implements $VendorCreateModelCopyWith<$Res> {
  factory _$VendorCreateModelCopyWith(_VendorCreateModel value, $Res Function(_VendorCreateModel) _then) = __$VendorCreateModelCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: "name") String? name,@JsonKey(name: "email") String? email,@JsonKey(name: "phone_number1") String? phoneNumber1,@JsonKey(name: "phone_number2") String? phoneNumber2,@JsonKey(name: "description") String? description,@JsonKey(name: "address") String? address,@JsonKey(name: "latitude") String? latitude,@JsonKey(name: "longitude") String? longitude,@JsonKey(name: "certificate_files") List<String>? certificateFiles,@JsonKey(name: "workdays") List<Workday>? workdays,@JsonKey(name: "categories") List<int>? categories
});




}
/// @nodoc
class __$VendorCreateModelCopyWithImpl<$Res>
    implements _$VendorCreateModelCopyWith<$Res> {
  __$VendorCreateModelCopyWithImpl(this._self, this._then);

  final _VendorCreateModel _self;
  final $Res Function(_VendorCreateModel) _then;

/// Create a copy of VendorCreateModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? email = freezed,Object? phoneNumber1 = freezed,Object? phoneNumber2 = freezed,Object? description = freezed,Object? address = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? certificateFiles = freezed,Object? workdays = freezed,Object? categories = freezed,}) {
  return _then(_VendorCreateModel(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber1: freezed == phoneNumber1 ? _self.phoneNumber1 : phoneNumber1 // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber2: freezed == phoneNumber2 ? _self.phoneNumber2 : phoneNumber2 // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,certificateFiles: freezed == certificateFiles ? _self._certificateFiles : certificateFiles // ignore: cast_nullable_to_non_nullable
as List<String>?,workdays: freezed == workdays ? _self._workdays : workdays // ignore: cast_nullable_to_non_nullable
as List<Workday>?,categories: freezed == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<int>?,
  ));
}


}


/// @nodoc
mixin _$Workday {

@JsonKey(name: "day") String? get day;@JsonKey(name: "from_time") String? get fromTime;@JsonKey(name: "to_time") String? get toTime;@JsonKey(name: "status") String? get status;
/// Create a copy of Workday
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WorkdayCopyWith<Workday> get copyWith => _$WorkdayCopyWithImpl<Workday>(this as Workday, _$identity);

  /// Serializes this Workday to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Workday&&(identical(other.day, day) || other.day == day)&&(identical(other.fromTime, fromTime) || other.fromTime == fromTime)&&(identical(other.toTime, toTime) || other.toTime == toTime)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,fromTime,toTime,status);

@override
String toString() {
  return 'Workday(day: $day, fromTime: $fromTime, toTime: $toTime, status: $status)';
}


}

/// @nodoc
abstract mixin class $WorkdayCopyWith<$Res>  {
  factory $WorkdayCopyWith(Workday value, $Res Function(Workday) _then) = _$WorkdayCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: "day") String? day,@JsonKey(name: "from_time") String? fromTime,@JsonKey(name: "to_time") String? toTime,@JsonKey(name: "status") String? status
});




}
/// @nodoc
class _$WorkdayCopyWithImpl<$Res>
    implements $WorkdayCopyWith<$Res> {
  _$WorkdayCopyWithImpl(this._self, this._then);

  final Workday _self;
  final $Res Function(Workday) _then;

/// Create a copy of Workday
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? day = freezed,Object? fromTime = freezed,Object? toTime = freezed,Object? status = freezed,}) {
  return _then(_self.copyWith(
day: freezed == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String?,fromTime: freezed == fromTime ? _self.fromTime : fromTime // ignore: cast_nullable_to_non_nullable
as String?,toTime: freezed == toTime ? _self.toTime : toTime // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Workday].
extension WorkdayPatterns on Workday {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Workday value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Workday() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Workday value)  $default,){
final _that = this;
switch (_that) {
case _Workday():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Workday value)?  $default,){
final _that = this;
switch (_that) {
case _Workday() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: "day")  String? day, @JsonKey(name: "from_time")  String? fromTime, @JsonKey(name: "to_time")  String? toTime, @JsonKey(name: "status")  String? status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Workday() when $default != null:
return $default(_that.day,_that.fromTime,_that.toTime,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: "day")  String? day, @JsonKey(name: "from_time")  String? fromTime, @JsonKey(name: "to_time")  String? toTime, @JsonKey(name: "status")  String? status)  $default,) {final _that = this;
switch (_that) {
case _Workday():
return $default(_that.day,_that.fromTime,_that.toTime,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: "day")  String? day, @JsonKey(name: "from_time")  String? fromTime, @JsonKey(name: "to_time")  String? toTime, @JsonKey(name: "status")  String? status)?  $default,) {final _that = this;
switch (_that) {
case _Workday() when $default != null:
return $default(_that.day,_that.fromTime,_that.toTime,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Workday implements Workday {
  const _Workday({@JsonKey(name: "day") this.day, @JsonKey(name: "from_time") this.fromTime, @JsonKey(name: "to_time") this.toTime, @JsonKey(name: "status") this.status});
  factory _Workday.fromJson(Map<String, dynamic> json) => _$WorkdayFromJson(json);

@override@JsonKey(name: "day") final  String? day;
@override@JsonKey(name: "from_time") final  String? fromTime;
@override@JsonKey(name: "to_time") final  String? toTime;
@override@JsonKey(name: "status") final  String? status;

/// Create a copy of Workday
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WorkdayCopyWith<_Workday> get copyWith => __$WorkdayCopyWithImpl<_Workday>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WorkdayToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Workday&&(identical(other.day, day) || other.day == day)&&(identical(other.fromTime, fromTime) || other.fromTime == fromTime)&&(identical(other.toTime, toTime) || other.toTime == toTime)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,day,fromTime,toTime,status);

@override
String toString() {
  return 'Workday(day: $day, fromTime: $fromTime, toTime: $toTime, status: $status)';
}


}

/// @nodoc
abstract mixin class _$WorkdayCopyWith<$Res> implements $WorkdayCopyWith<$Res> {
  factory _$WorkdayCopyWith(_Workday value, $Res Function(_Workday) _then) = __$WorkdayCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: "day") String? day,@JsonKey(name: "from_time") String? fromTime,@JsonKey(name: "to_time") String? toTime,@JsonKey(name: "status") String? status
});




}
/// @nodoc
class __$WorkdayCopyWithImpl<$Res>
    implements _$WorkdayCopyWith<$Res> {
  __$WorkdayCopyWithImpl(this._self, this._then);

  final _Workday _self;
  final $Res Function(_Workday) _then;

/// Create a copy of Workday
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? day = freezed,Object? fromTime = freezed,Object? toTime = freezed,Object? status = freezed,}) {
  return _then(_Workday(
day: freezed == day ? _self.day : day // ignore: cast_nullable_to_non_nullable
as String?,fromTime: freezed == fromTime ? _self.fromTime : fromTime // ignore: cast_nullable_to_non_nullable
as String?,toTime: freezed == toTime ? _self.toTime : toTime // ignore: cast_nullable_to_non_nullable
as String?,status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
