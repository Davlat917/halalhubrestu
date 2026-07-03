part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthReset extends AuthEvent {
  const AuthReset();
}

final class LoginEmailSubmitted extends AuthEvent {
  const LoginEmailSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class SignUpEmailSubmitted extends AuthEvent {
  const SignUpEmailSubmitted({
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.password1,
    required this.password2,
    required this.role,
  });

  final String email;
  final String firstName;
  final String lastName;
  final String password1;
  final String password2;
  final String role;

  @override
  List<Object?> get props => [email, firstName, lastName, password1, password2, role];
}

final class VerifyOtpSubmitted extends AuthEvent {
  const VerifyOtpSubmitted({required this.credential, required this.otp});

  final String credential;
  final String otp;

  @override
  List<Object?> get props => [credential, otp];
}

final class ResetOtpRequested extends AuthEvent {
  const ResetOtpRequested({required this.credential});

  final String credential;

  @override
  List<Object?> get props => [credential];
}

final class PasswordResetRequestSubmitted extends AuthEvent {
  const PasswordResetRequestSubmitted({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

/// Parol tiklash OTP sahifasida: kodni tekshirish, token sessionga yoziladi.
final class PasswordResetOtpVerifySubmitted extends AuthEvent {
  const PasswordResetOtpVerifySubmitted({required this.email, required this.otp});

  final String email;
  final String otp;

  @override
  List<Object?> get props => [email, otp];
}

/// Parol tiklash OTP qayta yuborish (forgot bilan bir xil endpoint).
final class PasswordResetResendSubmitted extends AuthEvent {
  const PasswordResetResendSubmitted({required this.email});

  final String email;

  @override
  List<Object?> get props => [email];
}

final class PasswordResetConfirmSubmitted extends AuthEvent {
  const PasswordResetConfirmSubmitted({required this.resetToken, required this.newPassword});

  final String resetToken;
  final String newPassword;

  @override
  List<Object?> get props => [resetToken, newPassword];
}

final class LoginGoogleSubmitted extends AuthEvent {
  const LoginGoogleSubmitted();
}

final class LoginAppleSubmitted extends AuthEvent {
  const LoginAppleSubmitted();
}
