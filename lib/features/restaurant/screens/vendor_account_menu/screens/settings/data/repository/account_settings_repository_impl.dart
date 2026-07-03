import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart'
    show ExceptionHandler, NetworkException, UnexpectedException;
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/data/models/account_profile_model.dart';
import 'package:halalhub_restaurant/features/restaurant/screens/vendor_account_menu/screens/settings/data/repository/account_settings_repository.dart';

class AccountSettingsRepositoryImpl implements AccountSettingsRepository {
  const AccountSettingsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<AccountProfileModel> fetchProfile() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        Constants.accountsProfile,
      );
      final data = response.data;
      if (data == null) {
        throw NetworkException(message: 'Invalid profile response');
      }
      return AccountProfileModel.fromJson(data);
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      if (ex is UnexpectedException) {
        throw NetworkException(message: ex.message);
      }
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<String> requestPasswordReset({required String email}) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        Constants.passwordResetRequest,
        data: {'email': email},
      );
      final data = response.data;
      final detail = data?['detail'] ?? data?['message'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
      return TranslationKeys.changePasswordRequestSent.tr();
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      if (ex is UnexpectedException) {
        throw NetworkException(message: ex.message);
      }
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<String> verifyPasswordReset({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        Constants.passwordResetVerify,
        data: {'email': email, 'code': code},
      );
      final data = response.data;
      final token = data?['reset_token'] ?? data?['token'] ?? data?['uid'];
      if (token != null && token.toString().trim().isNotEmpty) {
        return token.toString().trim();
      }
      throw NetworkException(
        message: TranslationKeys.authInvalidServerResponse.tr(),
      );
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      if (ex is UnexpectedException) {
        throw NetworkException(message: ex.message);
      }
      throw NetworkException(message: ex.toString());
    }
  }

  @override
  Future<String> confirmPasswordReset({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        Constants.passwordResetConfirm,
        data: {'reset_token': resetToken, 'new_password': newPassword},
      );
      final data = response.data;
      final detail = data?['detail'] ?? data?['message'];
      if (detail is String && detail.trim().isNotEmpty) {
        return detail.trim();
      }
      return TranslationKeys.authPasswordResetDone.tr();
    } catch (e) {
      final ex = ExceptionHandler.handleException(e);
      if (ex is NetworkException) throw ex;
      if (ex is UnexpectedException) {
        throw NetworkException(message: ex.message);
      }
      throw NetworkException(message: ex.toString());
    }
  }
}
