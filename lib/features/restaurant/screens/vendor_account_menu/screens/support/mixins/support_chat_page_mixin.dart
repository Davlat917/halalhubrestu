import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/bloc/support_chat_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/bloc/support_chat_event.dart';

/// [SupportChatPage] — scroll, matn maydoni va yuborish / qayta urinish / orqaga.
mixin SupportChatPageMixin<T extends StatefulWidget> on State<T> {
  late final ScrollController supportChatScrollController;
  late final TextEditingController supportChatTextController;

  void initSupportChatPageMixin() {
    supportChatScrollController = ScrollController();
    supportChatTextController = TextEditingController();
  }

  void disposeSupportChatPageMixin() {
    supportChatScrollController.dispose();
    supportChatTextController.dispose();
  }

  void supportChatScrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!supportChatScrollController.hasClients) return;
      supportChatScrollController.jumpTo(supportChatScrollController.position.maxScrollExtent);
    });
  }

  void onSupportChatSend(BuildContext context) {
    final t = supportChatTextController.text.trim();
    if (t.isEmpty) return;
    context.read<SupportChatBloc>().add(SupportChatSendRequested(t));
    supportChatTextController.clear();
  }

  void onSupportChatRetry(BuildContext context) {
    context.read<SupportChatBloc>().add(const SupportChatStarted());
  }

  void onSupportChatBack(BuildContext context) {
    context.router.maybePop();
  }
}
