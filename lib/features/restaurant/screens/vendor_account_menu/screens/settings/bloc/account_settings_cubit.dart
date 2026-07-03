import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/bloc/account_settings_state.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/data/repository/account_settings_repository.dart';

class AccountSettingsCubit extends Cubit<AccountSettingsState> {
  AccountSettingsCubit(this._repository) : super(const AccountSettingsState());

  final AccountSettingsRepository _repository;

  Future<void> loadProfile() async {
    emit(
      state.copyWith(status: AccountSettingsStatus.loading, clearError: true),
    );
    try {
      final profile = await _repository.fetchProfile();
      emit(
        state.copyWith(
          status: AccountSettingsStatus.success,
          profile: profile,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AccountSettingsStatus.failure,
          errorMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    emit(
      state.copyWith(
        passwordRequestStatus: AccountSettingsStatus.loading,
        clearPasswordMessage: true,
      ),
    );
    try {
      final message = await _repository.requestPasswordReset(email: email);
      emit(
        state.copyWith(
          passwordRequestStatus: AccountSettingsStatus.success,
          passwordMessage: message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          passwordRequestStatus: AccountSettingsStatus.failure,
          passwordMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> verifyPasswordReset({
    required String email,
    required String code,
  }) async {
    emit(
      state.copyWith(
        otpVerifyStatus: AccountSettingsStatus.loading,
        clearPasswordMessage: true,
      ),
    );
    try {
      final resetToken = await _repository.verifyPasswordReset(
        email: email,
        code: code,
      );
      emit(
        state.copyWith(
          otpVerifyStatus: AccountSettingsStatus.success,
          resetToken: resetToken,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          otpVerifyStatus: AccountSettingsStatus.failure,
          passwordMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  Future<void> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  }) async {
    emit(
      state.copyWith(
        passwordConfirmStatus: AccountSettingsStatus.loading,
        clearPasswordMessage: true,
      ),
    );
    try {
      final message = await _repository.confirmPasswordReset(
        resetToken: resetToken,
        newPassword: newPassword,
      );
      emit(
        state.copyWith(
          passwordConfirmStatus: AccountSettingsStatus.success,
          passwordMessage: message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          passwordConfirmStatus: AccountSettingsStatus.failure,
          passwordMessage: e is NetworkException ? e.message : e.toString(),
        ),
      );
    }
  }

  void resetPasswordEffect() {
    emit(
      state.copyWith(
        passwordRequestStatus: AccountSettingsStatus.initial,
        otpVerifyStatus: AccountSettingsStatus.initial,
        passwordConfirmStatus: AccountSettingsStatus.initial,
        clearPasswordMessage: true,
        clearResetToken: true,
      ),
    );
  }
}
