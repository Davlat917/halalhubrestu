import 'package:halalhub_restaurant/features/auth/bloc/auth_bloc.dart';

/// OTP / qayta yuborish / parol tiklash OTP — [OtpPageBody] listenerida ko‘rsatiladi.
/// Stack ostida qolgan SignUp / SignIn consumerrlari shu o‘tishda dialog ochmasligi kerak.
bool authFailureShouldBeHandledOnlyOnOtpPage(AuthState previous) {
  if (previous is! AuthLoading) return false;
  switch (previous.action) {
    case AuthPendingAction.verifyOtp:
    case AuthPendingAction.resetOtp:
    case AuthPendingAction.passwordResetOtpVerify:
    case AuthPendingAction.passwordResetResend:
      return true;
    default:
      return false;
  }
}
