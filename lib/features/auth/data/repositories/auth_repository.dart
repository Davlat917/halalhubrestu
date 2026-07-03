abstract class AuthRepository {
  // Sign up email
  Future<void> signUpEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String password1,
    required String password2,
    required String role, //
  });

  // login email
  Future<void> loginEmail({
    required String email,
    required String password, //
  });

  // verify otp
  Future<void> verifyOtp({
    required String credential,
    required String otp, //
  });

  // reset otp request
  Future<void> resetOtpRequest({required String credential});

  // password reset request
  Future<void> passwordResetRequest({required String email});

  // password reset verify
  Future<String> passwordResetVerify({
    required String email,
    required String code, //
  });

  // password reset confirm
  Future<String> passwordResetConfirm({
    required String resetToken,
    required String newPassword, //
  });

  // login with apple
  Future<void> loginWithApple({
    required String accessToken,
    required String code, //
    required String idToken, //
  });

  // login with google
  Future<void> loginWithGoogle({required String accessToken});

  // update role 
  Future<void> updateRole();
}
