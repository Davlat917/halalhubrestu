import 'package:auto_route/auto_route.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/mixins/validation_mixin.dart';
import 'package:halalhub_restaurant/core/theme/app_textstyle/app_text_style.dart';
import 'package:halalhub_restaurant/core/theme/colors/static_colors.dart';
import 'package:halalhub_restaurant/core/widgets/circle_btn_widget.dart';
import 'package:halalhub_restaurant/core/widgets/responsive_section.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/bloc/account_settings_cubit.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/bloc/account_settings_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/data/repository/account_settings_repository_impl.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/mixins/change_password_confirm_page_mixin.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/screens/change_password_confirm/sections/change_password_confirm_form_section.dart';

@RoutePage()
class ChangePasswordConfirmPage extends ResponsiveSection {
  const ChangePasswordConfirmPage({super.key, required this.resetToken});

  final String resetToken;

  @override
  Widget buildMobile(BuildContext context) {
    return ChangePasswordConfirmScaffold(
      resetToken: resetToken,
      maxContentWidth: null,
    );
  }

  @override
  Widget buildTablet(BuildContext context) {
    return ChangePasswordConfirmScaffold(
      resetToken: resetToken,
      maxContentWidth: 720,
    );
  }

  @override
  Widget buildDesktop(BuildContext context) => buildTablet(context);
}

class ChangePasswordConfirmScaffold extends StatefulWidget {
  const ChangePasswordConfirmScaffold({
    super.key,
    required this.resetToken,
    required this.maxContentWidth,
  });

  final String resetToken;
  final double? maxContentWidth;

  @override
  State<ChangePasswordConfirmScaffold> createState() =>
      _ChangePasswordConfirmScaffoldState();
}

class _ChangePasswordConfirmScaffoldState
    extends State<ChangePasswordConfirmScaffold>
    with ValidationMixin, ChangePasswordConfirmPageMixin {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AccountSettingsCubit(AccountSettingsRepositoryImpl(getIt<Dio>())),
      child: BlocConsumer<AccountSettingsCubit, AccountSettingsState>(
        listener: listenPasswordConfirm,
        builder: (context, state) {
          final isLoading =
              state.passwordConfirmStatus == AccountSettingsStatus.loading;
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
                TranslationKeys.resetPassword.tr(context: context),
                style: AppTextStyle.semibold18(context),
              ),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(height: 1, color: StaticColors.cE2E2E2),
              ),
            ),
            body: SafeArea(
              child: ChangePasswordConfirmFormSection(
                formKey: formKey,
                passwordController: passwordController,
                confirmPasswordController: confirmPasswordController,
                isLoading: isLoading,
                validatePassword: validatePassword,
                validateConfirmPassword: (value) =>
                    validateConfirmPassword(value, passwordController.text),
                maxContentWidth: widget.maxContentWidth,
                onSubmit: () => submitPasswordConfirm(context),
              ),
            ),
          );
        },
      ),
    );
  }
}
