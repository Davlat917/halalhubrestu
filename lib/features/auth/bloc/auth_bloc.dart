import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/di/base_bloc.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/auth/auth_error_ui.dart';
import 'package:halalhub_restaurant/features/auth/data/helper/social_auth.dart';
import 'package:halalhub_restaurant/features/auth/password_reset_session.dart';
import 'package:halalhub_restaurant/features/auth/data/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends BaseBloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository, this._socialAuth) : super(const AuthInitial()) {
    on<AuthReset>((_, emit) => emit(const AuthInitial()));

    on<LoginEmailSubmitted>(_onLoginEmail);
    on<SignUpEmailSubmitted>(_onSignUpEmail);
    on<VerifyOtpSubmitted>(_onVerifyOtp);
    on<ResetOtpRequested>(_onResetOtp);
    on<PasswordResetRequestSubmitted>(_onPasswordResetRequest);
    on<PasswordResetResendSubmitted>(_onPasswordResetResend);
    on<PasswordResetOtpVerifySubmitted>(_onPasswordResetOtpVerify);
    on<PasswordResetConfirmSubmitted>(_onPasswordResetConfirm);
    on<LoginGoogleSubmitted>(_onLoginGoogle);
    on<LoginAppleSubmitted>(_onLoginApple);
  }

  final AuthRepository _authRepository;
  final SocialAuth _socialAuth;

  NetworkException _asNetworkException(Object e) {
    if (e is NetworkException) return e;
    return NetworkException(message: e.toString());
  }

  void _emitFailure(Emitter<AuthState> emit, Object e) {
    final ex = _asNetworkException(e);
    emit(AuthFailure(exception: ex, preferDialog: authErrorPreferDialog(ex)));
  }

  Future<void> _onLoginEmail(LoginEmailSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(AuthPendingAction.loginEmail));
    try {
      await _authRepository.loginEmail(email: event.email, password: event.password);
      await _authRepository.updateRole();
      emit(const AuthSuccess(message: 'Signed in successfully.'));
    } catch (e) {
      _emitFailure(emit, e);
    }
  }

  Future<void> _onSignUpEmail(SignUpEmailSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(AuthPendingAction.signUpEmail));
    try {
      await _authRepository.signUpEmail(
        email: event.email,
        firstName: event.firstName,
        lastName: event.lastName,
        password1: event.password1,
        password2: event.password2,
        role: event.role,
      );
      emit(const AuthSuccess(message: 'Verification code sent.'));
    } catch (e) {
      _emitFailure(emit, e);
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(AuthPendingAction.verifyOtp));
    try {
      await _authRepository.verifyOtp(credential: event.credential, otp: event.otp);
      await _authRepository.updateRole();
      emit(const AuthSuccess(message: 'Verified successfully.'));
    } catch (e) {
      _emitFailure(emit, e);
    }
  }

  Future<void> _onResetOtp(ResetOtpRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(AuthPendingAction.resetOtp));
    try {
      await _authRepository.resetOtpRequest(credential: event.credential);
      emit(const AuthSuccess(message: 'Code sent again.'));
    } catch (e) {
      _emitFailure(emit, e);
    }
  }

  Future<void> _onPasswordResetRequest(PasswordResetRequestSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(AuthPendingAction.passwordResetRequest));
    try {
      await _authRepository.passwordResetRequest(email: event.email);
      emit(const AuthSuccess(message: 'Verification code sent to your email.'));
    } catch (e) {
      _emitFailure(emit, e);
    }
  }

  Future<void> _onPasswordResetResend(PasswordResetResendSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(AuthPendingAction.passwordResetResend));
    try {
      await _authRepository.passwordResetRequest(email: event.email);
      emit(const AuthSuccess(message: 'Code sent again.'));
    } catch (e) {
      _emitFailure(emit, e);
    }
  }

  Future<void> _onPasswordResetOtpVerify(PasswordResetOtpVerifySubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(AuthPendingAction.passwordResetOtpVerify));
    try {
      final token = await _authRepository.passwordResetVerify(email: event.email, code: event.otp);
      PasswordResetSession.pendingResetToken = token;
      emit(const AuthSuccess(message: 'Code verified.'));
    } catch (e) {
      _emitFailure(emit, e);
    }
  }

  Future<void> _onPasswordResetConfirm(PasswordResetConfirmSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(AuthPendingAction.passwordResetConfirm));
    try {
      final msg = await _authRepository.passwordResetConfirm(resetToken: event.resetToken, newPassword: event.newPassword);
      emit(AuthSuccess(message: msg));
    } catch (e) {
      _emitFailure(emit, e);
    }
  }

  Future<void> _onLoginGoogle(LoginGoogleSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(AuthPendingAction.loginGoogle));
    try {
      final result = await _socialAuth.signInWithGoogleFirebase();
      final err = result['errorMessage'];
      if (err != null && err.isNotEmpty) {
        emit(AuthFailure(exception: NetworkException(message: err), preferDialog: false));
        return;
      }
      emit(const AuthSuccess(message: 'Signed in with Google.'));
    } catch (e) {
      _emitFailure(emit, e);
    }
  }

  Future<void> _onLoginApple(LoginAppleSubmitted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading(AuthPendingAction.loginApple));
    try {
      final result = await _socialAuth.signInWithApple();
      final err = result['errorMessage'];
      if (err != null && err.isNotEmpty) {
        emit(AuthFailure(exception: NetworkException(message: err), preferDialog: false));
        return;
      }
      emit(const AuthSuccess(message: 'Signed in with Apple.'));
    } catch (e) {
      _emitFailure(emit, e);
    }
  }
}
