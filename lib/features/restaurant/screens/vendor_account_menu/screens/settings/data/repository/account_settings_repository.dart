import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/data/models/account_profile_model.dart';

abstract class AccountSettingsRepository {
  Future<AccountProfileModel> fetchProfile();
  Future<String> requestPasswordReset({required String email});
  Future<String> verifyPasswordReset({
    required String email,
    required String code,
  });
  Future<String> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  });
}
