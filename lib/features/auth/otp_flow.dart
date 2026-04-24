/// OTP sahifasining maqsadi: akkaunt tasdiqlash yoki parol tiklash.
enum OtpFlow {
  /// Ro‘yxatdan o‘tish / kirish OTP — verify-otp + token.
  account,

  /// Parol tiklash — kodni password-reset/verify orqali tekshirish.
  passwordReset,
}
