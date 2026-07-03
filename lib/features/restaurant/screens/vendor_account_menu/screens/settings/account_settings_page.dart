import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/circle_btn_widget.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/bloc/account_settings_cubit.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/bloc/account_settings_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/data/repository/account_settings_repository_impl.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/sections/account_settings_body_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/widgets/account_settings_error_view.dart';

@RoutePage()
class AccountSettingsPage extends ResponsiveSection {
  const AccountSettingsPage({super.key});

  @override
  Widget buildMobile(BuildContext context) {
    return const _AccountSettingsScaffold(maxContentWidth: null);
  }

  @override
  Widget buildTablet(BuildContext context) {
    return const _AccountSettingsScaffold(maxContentWidth: 720);
  }

  @override
  Widget buildDesktop(BuildContext context) => buildTablet(context);
}

class _AccountSettingsScaffold extends StatelessWidget {
  const _AccountSettingsScaffold({required this.maxContentWidth});

  final double? maxContentWidth;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AccountSettingsCubit(AccountSettingsRepositoryImpl(getIt<Dio>()))
            ..loadProfile(),
      child: Scaffold(
        backgroundColor: StaticColors.cF8F8F8,
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: StaticColors.white,
          surfaceTintColor: Colors.transparent,
          leading: Align(
            alignment: Alignment.center,
            child: CircleBtnWidget(
              bgColor: StaticColors.white,
              iconColor: StaticColors.black,
              onPress: () => context.router.maybePop(),
            ),
          ),
          title: Text(
            TranslationKeys.settings.tr(context: context),
            style: AppTextStyle.semibold18(context),
          ),
          centerTitle: true,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: StaticColors.cE2E2E2),
          ),
        ),
        body: SafeArea(
          child: BlocBuilder<AccountSettingsCubit, AccountSettingsState>(
            builder: (context, state) {
              if (state.status == AccountSettingsStatus.loading ||
                  state.status == AccountSettingsStatus.initial) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }

              final profile = state.profile;
              if (state.status == AccountSettingsStatus.failure ||
                  profile == null) {
                return AccountSettingsErrorView(
                  onRetry: () =>
                      context.read<AccountSettingsCubit>().loadProfile(),
                );
              }

              return AccountSettingsBodySection(
                profile: profile,
                maxContentWidth: maxContentWidth,
              );
            },
          ),
        ),
      ),
    );
  }
}
