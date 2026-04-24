import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/data/models/service_support_chat_model.dart';

enum SupportChatStatus { initial, connecting, ready, failure, disconnected }

class SupportChatState extends Equatable {
  const SupportChatState({
    this.status = SupportChatStatus.initial,
    this.messages = const [],
    this.errorMessage,
  });

  final SupportChatStatus status;
  final List<Message> messages;
  final String? errorMessage;

  SupportChatState copyWith({
    SupportChatStatus? status,
    List<Message>? messages,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SupportChatState(
      status: status ?? this.status,
      messages: messages ?? this.messages,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, messages, errorMessage];
}
