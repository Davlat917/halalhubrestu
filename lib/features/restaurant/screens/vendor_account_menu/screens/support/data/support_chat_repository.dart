import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/data/models/service_support_chat_model.dart';

abstract class SupportChatRepository {
  Stream<ServiceSupportChatModel> get inbound;

  Future<void> connect();

  Future<void> disconnect();

  void sendText(String content);
}
