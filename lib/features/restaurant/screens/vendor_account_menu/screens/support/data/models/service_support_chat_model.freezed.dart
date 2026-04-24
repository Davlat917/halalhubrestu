// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_support_chat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ServiceSupportChatModel {

 String? get type;/// Tarix (history) — birinchi yuklanishda.
 List<Message>? get messages;/// Realtime xabar.
 Message? get message;
/// Create a copy of ServiceSupportChatModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ServiceSupportChatModelCopyWith<ServiceSupportChatModel> get copyWith => _$ServiceSupportChatModelCopyWithImpl<ServiceSupportChatModel>(this as ServiceSupportChatModel, _$identity);

  /// Serializes this ServiceSupportChatModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ServiceSupportChatModel&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(messages),message);

@override
String toString() {
  return 'ServiceSupportChatModel(type: $type, messages: $messages, message: $message)';
}


}

/// @nodoc
abstract mixin class $ServiceSupportChatModelCopyWith<$Res>  {
  factory $ServiceSupportChatModelCopyWith(ServiceSupportChatModel value, $Res Function(ServiceSupportChatModel) _then) = _$ServiceSupportChatModelCopyWithImpl;
@useResult
$Res call({
 String? type, List<Message>? messages, Message? message
});


$MessageCopyWith<$Res>? get message;

}
/// @nodoc
class _$ServiceSupportChatModelCopyWithImpl<$Res>
    implements $ServiceSupportChatModelCopyWith<$Res> {
  _$ServiceSupportChatModelCopyWithImpl(this._self, this._then);

  final ServiceSupportChatModel _self;
  final $Res Function(ServiceSupportChatModel) _then;

/// Create a copy of ServiceSupportChatModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = freezed,Object? messages = freezed,Object? message = freezed,}) {
  return _then(_self.copyWith(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,messages: freezed == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as Message?,
  ));
}
/// Create a copy of ServiceSupportChatModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res>? get message {
    if (_self.message == null) {
    return null;
  }

  return $MessageCopyWith<$Res>(_self.message!, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}


/// Adds pattern-matching-related methods to [ServiceSupportChatModel].
extension ServiceSupportChatModelPatterns on ServiceSupportChatModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ServiceSupportChatModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ServiceSupportChatModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ServiceSupportChatModel value)  $default,){
final _that = this;
switch (_that) {
case _ServiceSupportChatModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ServiceSupportChatModel value)?  $default,){
final _that = this;
switch (_that) {
case _ServiceSupportChatModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? type,  List<Message>? messages,  Message? message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ServiceSupportChatModel() when $default != null:
return $default(_that.type,_that.messages,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? type,  List<Message>? messages,  Message? message)  $default,) {final _that = this;
switch (_that) {
case _ServiceSupportChatModel():
return $default(_that.type,_that.messages,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? type,  List<Message>? messages,  Message? message)?  $default,) {final _that = this;
switch (_that) {
case _ServiceSupportChatModel() when $default != null:
return $default(_that.type,_that.messages,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ServiceSupportChatModel implements ServiceSupportChatModel {
  const _ServiceSupportChatModel({this.type, final  List<Message>? messages, this.message}): _messages = messages;
  factory _ServiceSupportChatModel.fromJson(Map<String, dynamic> json) => _$ServiceSupportChatModelFromJson(json);

@override final  String? type;
/// Tarix (history) — birinchi yuklanishda.
 final  List<Message>? _messages;
/// Tarix (history) — birinchi yuklanishda.
@override List<Message>? get messages {
  final value = _messages;
  if (value == null) return null;
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Realtime xabar.
@override final  Message? message;

/// Create a copy of ServiceSupportChatModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ServiceSupportChatModelCopyWith<_ServiceSupportChatModel> get copyWith => __$ServiceSupportChatModelCopyWithImpl<_ServiceSupportChatModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ServiceSupportChatModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ServiceSupportChatModel&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,const DeepCollectionEquality().hash(_messages),message);

@override
String toString() {
  return 'ServiceSupportChatModel(type: $type, messages: $messages, message: $message)';
}


}

/// @nodoc
abstract mixin class _$ServiceSupportChatModelCopyWith<$Res> implements $ServiceSupportChatModelCopyWith<$Res> {
  factory _$ServiceSupportChatModelCopyWith(_ServiceSupportChatModel value, $Res Function(_ServiceSupportChatModel) _then) = __$ServiceSupportChatModelCopyWithImpl;
@override @useResult
$Res call({
 String? type, List<Message>? messages, Message? message
});


@override $MessageCopyWith<$Res>? get message;

}
/// @nodoc
class __$ServiceSupportChatModelCopyWithImpl<$Res>
    implements _$ServiceSupportChatModelCopyWith<$Res> {
  __$ServiceSupportChatModelCopyWithImpl(this._self, this._then);

  final _ServiceSupportChatModel _self;
  final $Res Function(_ServiceSupportChatModel) _then;

/// Create a copy of ServiceSupportChatModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = freezed,Object? messages = freezed,Object? message = freezed,}) {
  return _then(_ServiceSupportChatModel(
type: freezed == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String?,messages: freezed == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>?,message: freezed == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as Message?,
  ));
}

/// Create a copy of ServiceSupportChatModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MessageCopyWith<$Res>? get message {
    if (_self.message == null) {
    return null;
  }

  return $MessageCopyWith<$Res>(_self.message!, (value) {
    return _then(_self.copyWith(message: value));
  });
}
}


/// @nodoc
mixin _$Message {

@JsonKey(name: 'id') int? get id;@JsonKey(name: 'chat') int? get chat;@JsonKey(name: 'sender') Sender? get sender;@JsonKey(name: 'content') String? get content;@JsonKey(name: 'timestamp') DateTime? get timestamp;@JsonKey(name: 'from_user') bool? get fromUser;
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MessageCopyWith<Message> get copyWith => _$MessageCopyWithImpl<Message>(this as Message, _$identity);

  /// Serializes this Message to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Message&&(identical(other.id, id) || other.id == id)&&(identical(other.chat, chat) || other.chat == chat)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.content, content) || other.content == content)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.fromUser, fromUser) || other.fromUser == fromUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chat,sender,content,timestamp,fromUser);

@override
String toString() {
  return 'Message(id: $id, chat: $chat, sender: $sender, content: $content, timestamp: $timestamp, fromUser: $fromUser)';
}


}

/// @nodoc
abstract mixin class $MessageCopyWith<$Res>  {
  factory $MessageCopyWith(Message value, $Res Function(Message) _then) = _$MessageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') int? id,@JsonKey(name: 'chat') int? chat,@JsonKey(name: 'sender') Sender? sender,@JsonKey(name: 'content') String? content,@JsonKey(name: 'timestamp') DateTime? timestamp,@JsonKey(name: 'from_user') bool? fromUser
});


$SenderCopyWith<$Res>? get sender;

}
/// @nodoc
class _$MessageCopyWithImpl<$Res>
    implements $MessageCopyWith<$Res> {
  _$MessageCopyWithImpl(this._self, this._then);

  final Message _self;
  final $Res Function(Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? chat = freezed,Object? sender = freezed,Object? content = freezed,Object? timestamp = freezed,Object? fromUser = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,chat: freezed == chat ? _self.chat : chat // ignore: cast_nullable_to_non_nullable
as int?,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as Sender?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,fromUser: freezed == fromUser ? _self.fromUser : fromUser // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}
/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SenderCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $SenderCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// Adds pattern-matching-related methods to [Message].
extension MessagePatterns on Message {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Message value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Message value)  $default,){
final _that = this;
switch (_that) {
case _Message():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Message value)?  $default,){
final _that = this;
switch (_that) {
case _Message() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int? id, @JsonKey(name: 'chat')  int? chat, @JsonKey(name: 'sender')  Sender? sender, @JsonKey(name: 'content')  String? content, @JsonKey(name: 'timestamp')  DateTime? timestamp, @JsonKey(name: 'from_user')  bool? fromUser)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.chat,_that.sender,_that.content,_that.timestamp,_that.fromUser);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int? id, @JsonKey(name: 'chat')  int? chat, @JsonKey(name: 'sender')  Sender? sender, @JsonKey(name: 'content')  String? content, @JsonKey(name: 'timestamp')  DateTime? timestamp, @JsonKey(name: 'from_user')  bool? fromUser)  $default,) {final _that = this;
switch (_that) {
case _Message():
return $default(_that.id,_that.chat,_that.sender,_that.content,_that.timestamp,_that.fromUser);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  int? id, @JsonKey(name: 'chat')  int? chat, @JsonKey(name: 'sender')  Sender? sender, @JsonKey(name: 'content')  String? content, @JsonKey(name: 'timestamp')  DateTime? timestamp, @JsonKey(name: 'from_user')  bool? fromUser)?  $default,) {final _that = this;
switch (_that) {
case _Message() when $default != null:
return $default(_that.id,_that.chat,_that.sender,_that.content,_that.timestamp,_that.fromUser);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Message implements Message {
  const _Message({@JsonKey(name: 'id') this.id, @JsonKey(name: 'chat') this.chat, @JsonKey(name: 'sender') this.sender, @JsonKey(name: 'content') this.content, @JsonKey(name: 'timestamp') this.timestamp, @JsonKey(name: 'from_user') this.fromUser});
  factory _Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);

@override@JsonKey(name: 'id') final  int? id;
@override@JsonKey(name: 'chat') final  int? chat;
@override@JsonKey(name: 'sender') final  Sender? sender;
@override@JsonKey(name: 'content') final  String? content;
@override@JsonKey(name: 'timestamp') final  DateTime? timestamp;
@override@JsonKey(name: 'from_user') final  bool? fromUser;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MessageCopyWith<_Message> get copyWith => __$MessageCopyWithImpl<_Message>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MessageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Message&&(identical(other.id, id) || other.id == id)&&(identical(other.chat, chat) || other.chat == chat)&&(identical(other.sender, sender) || other.sender == sender)&&(identical(other.content, content) || other.content == content)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.fromUser, fromUser) || other.fromUser == fromUser));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,chat,sender,content,timestamp,fromUser);

@override
String toString() {
  return 'Message(id: $id, chat: $chat, sender: $sender, content: $content, timestamp: $timestamp, fromUser: $fromUser)';
}


}

/// @nodoc
abstract mixin class _$MessageCopyWith<$Res> implements $MessageCopyWith<$Res> {
  factory _$MessageCopyWith(_Message value, $Res Function(_Message) _then) = __$MessageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') int? id,@JsonKey(name: 'chat') int? chat,@JsonKey(name: 'sender') Sender? sender,@JsonKey(name: 'content') String? content,@JsonKey(name: 'timestamp') DateTime? timestamp,@JsonKey(name: 'from_user') bool? fromUser
});


@override $SenderCopyWith<$Res>? get sender;

}
/// @nodoc
class __$MessageCopyWithImpl<$Res>
    implements _$MessageCopyWith<$Res> {
  __$MessageCopyWithImpl(this._self, this._then);

  final _Message _self;
  final $Res Function(_Message) _then;

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? chat = freezed,Object? sender = freezed,Object? content = freezed,Object? timestamp = freezed,Object? fromUser = freezed,}) {
  return _then(_Message(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,chat: freezed == chat ? _self.chat : chat // ignore: cast_nullable_to_non_nullable
as int?,sender: freezed == sender ? _self.sender : sender // ignore: cast_nullable_to_non_nullable
as Sender?,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,fromUser: freezed == fromUser ? _self.fromUser : fromUser // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

/// Create a copy of Message
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SenderCopyWith<$Res>? get sender {
    if (_self.sender == null) {
    return null;
  }

  return $SenderCopyWith<$Res>(_self.sender!, (value) {
    return _then(_self.copyWith(sender: value));
  });
}
}


/// @nodoc
mixin _$Sender {

@JsonKey(name: 'id') int? get id;@JsonKey(name: 'username') String? get username;@JsonKey(name: 'email') String? get email;
/// Create a copy of Sender
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SenderCopyWith<Sender> get copyWith => _$SenderCopyWithImpl<Sender>(this as Sender, _$identity);

  /// Serializes this Sender to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sender&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,email);

@override
String toString() {
  return 'Sender(id: $id, username: $username, email: $email)';
}


}

/// @nodoc
abstract mixin class $SenderCopyWith<$Res>  {
  factory $SenderCopyWith(Sender value, $Res Function(Sender) _then) = _$SenderCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') int? id,@JsonKey(name: 'username') String? username,@JsonKey(name: 'email') String? email
});




}
/// @nodoc
class _$SenderCopyWithImpl<$Res>
    implements $SenderCopyWith<$Res> {
  _$SenderCopyWithImpl(this._self, this._then);

  final Sender _self;
  final $Res Function(Sender) _then;

/// Create a copy of Sender
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? username = freezed,Object? email = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Sender].
extension SenderPatterns on Sender {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sender value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sender() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sender value)  $default,){
final _that = this;
switch (_that) {
case _Sender():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sender value)?  $default,){
final _that = this;
switch (_that) {
case _Sender() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int? id, @JsonKey(name: 'username')  String? username, @JsonKey(name: 'email')  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sender() when $default != null:
return $default(_that.id,_that.username,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  int? id, @JsonKey(name: 'username')  String? username, @JsonKey(name: 'email')  String? email)  $default,) {final _that = this;
switch (_that) {
case _Sender():
return $default(_that.id,_that.username,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  int? id, @JsonKey(name: 'username')  String? username, @JsonKey(name: 'email')  String? email)?  $default,) {final _that = this;
switch (_that) {
case _Sender() when $default != null:
return $default(_that.id,_that.username,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Sender implements Sender {
  const _Sender({@JsonKey(name: 'id') this.id, @JsonKey(name: 'username') this.username, @JsonKey(name: 'email') this.email});
  factory _Sender.fromJson(Map<String, dynamic> json) => _$SenderFromJson(json);

@override@JsonKey(name: 'id') final  int? id;
@override@JsonKey(name: 'username') final  String? username;
@override@JsonKey(name: 'email') final  String? email;

/// Create a copy of Sender
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SenderCopyWith<_Sender> get copyWith => __$SenderCopyWithImpl<_Sender>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SenderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sender&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,email);

@override
String toString() {
  return 'Sender(id: $id, username: $username, email: $email)';
}


}

/// @nodoc
abstract mixin class _$SenderCopyWith<$Res> implements $SenderCopyWith<$Res> {
  factory _$SenderCopyWith(_Sender value, $Res Function(_Sender) _then) = __$SenderCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') int? id,@JsonKey(name: 'username') String? username,@JsonKey(name: 'email') String? email
});




}
/// @nodoc
class __$SenderCopyWithImpl<$Res>
    implements _$SenderCopyWith<$Res> {
  __$SenderCopyWithImpl(this._self, this._then);

  final _Sender _self;
  final $Res Function(_Sender) _then;

/// Create a copy of Sender
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? username = freezed,Object? email = freezed,}) {
  return _then(_Sender(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int?,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
