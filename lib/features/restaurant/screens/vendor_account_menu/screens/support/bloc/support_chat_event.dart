import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/data/models/service_support_chat_model.dart';

sealed class SupportChatEvent extends Equatable {
  const SupportChatEvent();

  @override
  List<Object?> get props => [];
}

final class SupportChatStarted extends SupportChatEvent {
  const SupportChatStarted();
}

final class SupportChatInbound extends SupportChatEvent {
  const SupportChatInbound(this.model);

  final ServiceSupportChatModel model;

  @override
  List<Object?> get props => [model];
}

final class SupportChatSendRequested extends SupportChatEvent {
  const SupportChatSendRequested(this.text);

  final String text;

  @override
  List<Object?> get props => [text];
}

final class SupportChatClosed extends SupportChatEvent {
  const SupportChatClosed();
}
