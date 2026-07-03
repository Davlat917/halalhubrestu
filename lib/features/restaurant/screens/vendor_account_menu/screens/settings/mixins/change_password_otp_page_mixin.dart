import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/di/injection.dart';
import 'package:halalhub_restaurant/core/router/app_router.dart';
import 'package:halalhub_restaurant/core/widgets/display/display.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/bloc/account_settings_cubit.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/bloc/account_settings_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/screens/change_password_otp/change_password_otp_page.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

mixin ChangePasswordOtpPageMixin on State<ChangePasswordOtpScaffold> {
  static const otpLength = 6;

  late final PinInputController otpController = PinInputController();
  late final ValueNotifier<String> otpValue = ValueNotifier<String>('');

  void onOtpChanged(String value) {
    otpValue.value = value;
  }

  void submitOtp(BuildContext context) {
    final code = otpValue.value.trim();
    if (code.length != otpLength) {
      getIt<Display>().error(
        TranslationKeys.changePasswordCodeRequired.tr(context: context),
      );
      return;
    }
    context.read<AccountSettingsCubit>().verifyPasswordReset(
      email: widget.email,
      code: code,
    );
  }

  void listenOtp(BuildContext context, AccountSettingsState state) {
    final message = state.passwordMessage;
    if (state.otpVerifyStatus == AccountSettingsStatus.success) {
      final resetToken = state.resetToken;
      if (resetToken == null || resetToken.isEmpty) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AccountSettingsCubit>().resetPasswordEffect();
        context.router.push(ChangePasswordConfirmRoute(resetToken: resetToken));
      });
      return;
    }
    if (state.otpVerifyStatus == AccountSettingsStatus.failure &&
        message != null) {
      getIt<Display>().error(message);
      context.read<AccountSettingsCubit>().resetPasswordEffect();
    }
  }

  @override
  void dispose() {
    otpValue.dispose();
    super.dispose();
  }
}
