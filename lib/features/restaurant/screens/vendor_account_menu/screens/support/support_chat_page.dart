import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/circle_btn_widget.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/bloc/support_chat_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/bloc/support_chat_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/bloc/support_chat_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/data/support_chat_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/mixins/support_chat_page_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/sections/support_chat_input_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/sections/support_chat_messages_body_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/support/widgets/support_chat_app_bar_logo.dart';

@RoutePage()
class SupportChatPage extends StatefulWidget {
  const SupportChatPage({super.key});

  @override
  State<SupportChatPage> createState() => _SupportChatPageState();
}

class _SupportChatPageState extends State<SupportChatPage> with SupportChatPageMixin {
  @override
  void initState() {
    super.initState();
    initSupportChatPageMixin();
  }

  @override
  void dispose() {
    disposeSupportChatPageMixin();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SupportChatBloc(getIt<SupportChatRepository>())..add(const SupportChatStarted()),
      child: BlocListener<SupportChatBloc, SupportChatState>(
        listenWhen: (p, c) => p.messages.length != c.messages.length,
        listener: (_, _) => supportChatScrollToBottom(),
        child: Scaffold(
          backgroundColor: StaticColors.white,
          appBar: AppBar(
            elevation: 0,
            scrolledUnderElevation: 0,
            backgroundColor: StaticColors.white,
            surfaceTintColor: Colors.transparent,
            leading: Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                child: CircleBtnWidget(
                  bgColor: StaticColors.backgroundColor,
                  iconColor: StaticColors.black,
                  onPress: () => onSupportChatBack(context), //
                ),
              ),
            ),
            titleSpacing: 18,
            title: Row(
              children: [
                const SupportChatAppBarLogo(),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(TranslationKeys.supportTitle.tr(context: context), style: AppTextStyle.semibold18(context, size: 16)),
                      Text(
                        TranslationKeys.supportOnline.tr(context: context),
                        style: AppTextStyle.medium14(context, size: 12, color: StaticColors.primary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: BlocBuilder<SupportChatBloc, SupportChatState>(
            builder: (context, state) {
              if (state.status == SupportChatStatus.connecting) {
                return const Center(child: CircularProgressIndicator.adaptive());
              }
              if (state.status == SupportChatStatus.failure && state.messages.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.errorMessage ?? TranslationKeys.supportConnectionFailed.tr(context: context),
                          textAlign: TextAlign.center,
                          style: AppTextStyle.regular14(context, color: StaticColors.c666666),
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => onSupportChatRetry(context),
                          child: Text(TranslationKeys.retry.tr(context: context)),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: [
                  Expanded(
                    child: SupportChatMessagesBodySection(messages: state.messages, scrollController: supportChatScrollController),
                  ),
                  SupportChatInputSection(controller: supportChatTextController, enabled: state.status == SupportChatStatus.ready, onSend: () => onSupportChatSend(context)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
