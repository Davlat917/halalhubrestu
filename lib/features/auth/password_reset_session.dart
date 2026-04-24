/// Parol tiklash: forgot → OTP → reset uchun email va verify dan keyin token.
class PasswordResetSession {
  PasswordResetSession._();

  static String? pendingEmail;
  static String? pendingResetToken;

  static void clear() {
    pendingEmail = null;
    pendingResetToken = null;
  }
}
