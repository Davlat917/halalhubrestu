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
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/mixins/change_password_otp_page_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/screens/change_password_otp/sections/change_password_otp_section.dart';

@RoutePage()
class ChangePasswordOtpPage extends ResponsiveSection {
  const ChangePasswordOtpPage({super.key, required this.email});

  final String email;

  @override
  Widget buildMobile(BuildContext context) {
    return ChangePasswordOtpScaffold(email: email, maxContentWidth: null);
  }

  @override
  Widget buildTablet(BuildContext context) {
    return ChangePasswordOtpScaffold(email: email, maxContentWidth: 720);
  }

  @override
  Widget buildDesktop(BuildContext context) => buildTablet(context);
}

class ChangePasswordOtpScaffold extends StatefulWidget {
  const ChangePasswordOtpScaffold({
    super.key,
    required this.email,
    required this.maxContentWidth,
  });

  final String email;
  final double? maxContentWidth;

  @override
  State<ChangePasswordOtpScaffold> createState() =>
      _ChangePasswordOtpScaffoldState();
}

class _ChangePasswordOtpScaffoldState extends State<ChangePasswordOtpScaffold>
    with ChangePasswordOtpPageMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AccountSettingsCubit(AccountSettingsRepositoryImpl(getIt<Dio>())),
      child: BlocConsumer<AccountSettingsCubit, AccountSettingsState>(
        listener: listenOtp,
        builder: (context, state) {
          final isLoading =
              state.otpVerifyStatus == AccountSettingsStatus.loading;
          return Scaffold(
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
                TranslationKeys.changePasswordOtpTitle.tr(context: context),
                style: AppTextStyle.semibold18(context),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: StaticColors.cE2E2E2),
              ),
            ),
            body: SafeArea(
              child: ChangePasswordOtpSection(
                email: widget.email,
                otpController: otpController,
                otpValue: otpValue,
                isLoading: isLoading,
                onChanged: onOtpChanged,
                onSubmit: () => submitOtp(context),
                maxContentWidth: widget.maxContentWidth,
              ),
            ),
          );
        },
      ),
    );
  }
}
