import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_support_chat_model.freezed.dart';
part 'service_support_chat_model.g.dart';

@freezed
abstract class ServiceSupportChatModel with _$ServiceSupportChatModel {
  const factory ServiceSupportChatModel({
    String? type,
    /// Tarix (history) — birinchi yuklanishda.
    List<Message>? messages,
    /// Realtime xabar.
    Message? message,
  }) = _ServiceSupportChatModel;

  factory ServiceSupportChatModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceSupportChatModelFromJson(json);
}

@freezed
abstract class Message with _$Message {
  const factory Message({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'chat') int? chat,
    @JsonKey(name: 'sender') Sender? sender,
    @JsonKey(name: 'content') String? content,
    @JsonKey(name: 'timestamp') DateTime? timestamp,
    @JsonKey(name: 'from_user') bool? fromUser,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) => _$MessageFromJson(json);
}

@freezed
abstract class Sender with _$Sender {
  const factory Sender({
    @JsonKey(name: 'id') int? id,
    @JsonKey(name: 'username') String? username,
    @JsonKey(name: 'email') String? email,
  }) = _Sender;

  factory Sender.fromJson(Map<String, dynamic> json) => _$SenderFromJson(json);
}
