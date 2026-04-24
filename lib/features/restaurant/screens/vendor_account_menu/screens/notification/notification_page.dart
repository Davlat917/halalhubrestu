import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/bloc/notification_bloc.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/bloc/notification_event.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/data/notifications_repository.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/notification/sections/notifications_body_section.dart';

@RoutePage()
class NotificationPage extends ResponsiveSection {
  const NotificationPage({super.key});

  @override
  Widget buildMobile(BuildContext context) => BlocProvider(
    create: (_) =>
        NotificationBloc(getIt<NotificationsRepository>())
          ..add(const NotificationsLoadRequested()),
    child: const _NotificationScaffold(isTablet: false),
  );

  @override
  Widget buildTablet(BuildContext context) => BlocProvider(
    create: (_) =>
        NotificationBloc(getIt<NotificationsRepository>())
          ..add(const NotificationsLoadRequested()),
    child: const _NotificationScaffold(isTablet: true),
  );

  @override
  Widget buildDesktop(BuildContext context) => buildTablet(context);
}

class _NotificationScaffold extends StatelessWidget {
  const _NotificationScaffold({required this.isTablet});

  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StaticColors.cF8F8F8,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: StaticColors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: StaticColors.black,
            size: 20,
          ),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          TranslationKeys.notificationsTitle.tr(context: context),
          style: AppTextStyle.semibold18(context),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: StaticColors.cE2E2E2),
        ),
      ),
      body: NotificationsBodySection(isTablet: isTablet),
    );
  }
}
