import 'package:equatable/equatable.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/data/models/account_profile_model.dart';

enum AccountSettingsStatus { initial, loading, success, failure }

class AccountSettingsState extends Equatable {
  const AccountSettingsState({
    this.status = AccountSettingsStatus.initial,
    this.passwordRequestStatus = AccountSettingsStatus.initial,
    this.otpVerifyStatus = AccountSettingsStatus.initial,
    this.passwordConfirmStatus = AccountSettingsStatus.initial,
    this.profile,
    this.errorMessage,
    this.passwordMessage,
    this.resetToken,
  });

  final AccountSettingsStatus status;
  final AccountSettingsStatus passwordRequestStatus;
  final AccountSettingsStatus otpVerifyStatus;
  final AccountSettingsStatus passwordConfirmStatus;
  final AccountProfileModel? profile;
  final String? errorMessage;
  final String? passwordMessage;
  final String? resetToken;

  AccountSettingsState copyWith({
    AccountSettingsStatus? status,
    AccountSettingsStatus? passwordRequestStatus,
    AccountSettingsStatus? otpVerifyStatus,
    AccountSettingsStatus? passwordConfirmStatus,
    AccountProfileModel? profile,
    String? errorMessage,
    String? passwordMessage,
    String? resetToken,
    bool clearError = false,
    bool clearPasswordMessage = false,
    bool clearResetToken = false,
  }) {
    return AccountSettingsState(
      status: status ?? this.status,
      passwordRequestStatus:
          passwordRequestStatus ?? this.passwordRequestStatus,
      otpVerifyStatus: otpVerifyStatus ?? this.otpVerifyStatus,
      passwordConfirmStatus:
          passwordConfirmStatus ?? this.passwordConfirmStatus,
      profile: profile ?? this.profile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      passwordMessage: clearPasswordMessage
          ? null
          : (passwordMessage ?? this.passwordMessage),
      resetToken: clearResetToken ? null : (resetToken ?? this.resetToken),
    );
  }

  @override
  List<Object?> get props => [
    status,
    passwordRequestStatus,
    otpVerifyStatus,
    passwordConfirmStatus,
    profile,
    errorMessage,
    passwordMessage,
    resetToken,
  ];
}
