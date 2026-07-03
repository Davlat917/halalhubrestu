import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/mixins/validation_mixin.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/bloc/account_settings_cubit.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/bloc/account_settings_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/screens/change_password/change_password_page.dart';

mixin ChangePasswordPageMixin
    on State<ChangePasswordScaffold>, ValidationMixin {
  late final formKey = GlobalKey<FormState>();
  late final emailController = TextEditingController(
    text: widget.initialEmail ?? '',
  );

  void submitChangePassword(BuildContext context) {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      final error = _firstFormError();
      if (error != null) getIt<Display>().error(error);
      return;
    }
    context.read<AccountSettingsCubit>().requestPasswordReset(
      email: emailController.text.trim(),
    );
  }

  void listenChangePassword(BuildContext context, AccountSettingsState state) {
    final message = state.passwordMessage;
    if (state.passwordRequestStatus == AccountSettingsStatus.success &&
        message != null) {
      final email = emailController.text.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        getIt<Display>().success(message);
        context.read<AccountSettingsCubit>().resetPasswordEffect();
        context.router.push(ChangePasswordOtpRoute(email: email));
      });
      return;
    }
    if (state.passwordRequestStatus == AccountSettingsStatus.failure &&
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
    emailController.dispose();
    super.dispose();
  }
}
