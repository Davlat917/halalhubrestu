// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_support_chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServiceSupportChatModel _$ServiceSupportChatModelFromJson(
  Map<String, dynamic> json,
) => _ServiceSupportChatModel(
  type: json['type'] as String?,
  messages: (json['messages'] as List<dynamic>?)
      ?.map((e) => Message.fromJson(e as Map<String, dynamic>))
      .toList(),
  message: json['message'] == null
      ? null
      : Message.fromJson(json['message'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ServiceSupportChatModelToJson(
  _ServiceSupportChatModel instance,
) => <String, dynamic>{
  'type': instance.type,
  'messages': instance.messages,
  'message': instance.message,
};

_Message _$MessageFromJson(Map<String, dynamic> json) => _Message(
  id: (json['id'] as num?)?.toInt(),
  chat: (json['chat'] as num?)?.toInt(),
  sender: json['sender'] == null
      ? null
      : Sender.fromJson(json['sender'] as Map<String, dynamic>),
  content: json['content'] as String?,
  timestamp: json['timestamp'] == null
      ? null
      : DateTime.parse(json['timestamp'] as String),
  fromUser: json['from_user'] as bool?,
);

Map<String, dynamic> _$MessageToJson(_Message instance) => <String, dynamic>{
  'id': instance.id,
  'chat': instance.chat,
  'sender': instance.sender,
  'content': instance.content,
  'timestamp': instance.timestamp?.toIso8601String(),
  'from_user': instance.fromUser,
};

_Sender _$SenderFromJson(Map<String, dynamic> json) => _Sender(
  id: (json['id'] as num?)?.toInt(),
  username: json['username'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$SenderToJson(_Sender instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
};
