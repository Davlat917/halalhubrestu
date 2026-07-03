part of 'auth_bloc.dart';

/// Qaysi auth operatsiyasi kutilayotgani — faqat shu tugmada loading spinner.
enum AuthPendingAction {
  loginEmail,
  signUpEmail,
  verifyOtp,
  resetOtp,
  passwordResetRequest,
  passwordResetResend,
  passwordResetOtpVerify,
  passwordResetConfirm,
  loginGoogle,
  loginApple,
}

sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

final class AuthInitial extends AuthState {
  const AuthInitial();
}

final class AuthLoading extends AuthState {
  const AuthLoading(this.action);

  final AuthPendingAction action;

  @override
  List<Object?> get props => [action];
}

final class AuthSuccess extends AuthState {
  const AuthSuccess({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

final class AuthFailure extends AuthState {
  const AuthFailure({required this.exception, required this.preferDialog});

  final NetworkException exception;
  final bool preferDialog;

  @override
  List<Object?> get props => [exception, preferDialog];
}
