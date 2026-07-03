import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/mixins/validation_mixin.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/bloc/account_settings_cubit.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/bloc/account_settings_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/screens/change_password_confirm/change_password_confirm_page.dart';

mixin ChangePasswordConfirmPageMixin
    on State<ChangePasswordConfirmScaffold>, ValidationMixin {
  late final formKey = GlobalKey<FormState>();
  late final passwordController = TextEditingController();
  late final confirmPasswordController = TextEditingController();

  void submitPasswordConfirm(BuildContext context) {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      final error = _firstFormError();
      if (error != null) getIt<Display>().error(error);
      return;
    }
    context.read<AccountSettingsCubit>().confirmPasswordReset(
      resetToken: widget.resetToken,
      newPassword: passwordController.text,
    );
  }

  void listenPasswordConfirm(BuildContext context, AccountSettingsState state) {
    final message = state.passwordMessage;
    if (state.passwordConfirmStatus == AccountSettingsStatus.success &&
        message != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AccountSettingsCubit>().resetPasswordEffect();
        context.router.popUntilRouteWithName(AccountSettingsRoute.name);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          getIt<Display>().success(message);
        });
      });
      return;
    }
    if (state.passwordConfirmStatus == AccountSettingsStatus.failure &&
        message != null) {
      getIt<Display>().error(message);
      context.read<AccountSettingsCubit>().resetPasswordEffect();
    }
  }

  String? _firstFormError() {
    final invalidFields = formKey.currentState?.validateGranularly();
    if (invalidFields == null || invalidFields.isEmpty) return null;
    return invalidFields.first.errorText;
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
