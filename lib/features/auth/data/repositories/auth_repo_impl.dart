import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/constants/translation_keys.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart';
import 'package:halalhub_restaurant/core/storage/storage.dart';
import 'package:halalhub_restaurant/features/auth/data/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AuthRepository)
class AuthRepoImpl extends AuthRepository {
  final Dio _dio;
  final Storage _storage;

  AuthRepoImpl({required Dio dio, required Storage storage})
    : _dio = dio,
      _storage = storage;

  static const _mobileHeaders = {'X-Client-Type': 'mobile'};

  Never _rethrow(Object e) {
    final ex = ExceptionHandler.handleException(e);
    if (ex is NetworkException) throw ex;
    if (ex is UnexpectedException) {
      throw NetworkException(message: ex.message);
    }
    throw NetworkException(message: ex.toString());
  }

  void _persistTokensFromBody(dynamic data) {
    if (data is! Map) return;
    final access = data['access'] ?? data['token'] ?? data['access_token'];
    final refresh = data['refresh'] ?? data['refresh_token'];
    if (access != null && access.toString().isNotEmpty) {
      _storage.token.set(access.toString());
    }
    if (refresh != null && refresh.toString().isNotEmpty) {
      _storage.refreshToken.set(refresh.toString());
    }
  }

  @override
  Future<void> loginEmail({
    required String email,
    required String password,
  }) async {
    await _storage.token.delete();
    try {
      final response = await _dio.post(
        Constants.loginEmail,
        data: {'email': email, 'password': password},
        options: Options(headers: _mobileHeaders),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _persistTokensFromBody(response.data);
        return;
      }
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<void> signUpEmail({
    required String email,
    required String firstName,
    required String lastName,
    required String password1,
    required String password2,
    required String role,
  }) async {
    try {
      await _dio.post(
        Constants.signupEmail,
        data: {
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'password1': password1,
          'password2': password2,
          'role': role,
        },
        options: Options(headers: _mobileHeaders),
      );
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<void> verifyOtp({
    required String credential,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        Constants.verifyOtp,
        data: {'credential': credential, 'otp': otp},
        options: Options(headers: _mobileHeaders),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _persistTokensFromBody(response.data);
      }
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<void> resetOtpRequest({required String credential}) async {
    try {
      await _dio.post(
        Constants.resetOtpRequest,
        data: {'credential': credential},
        options: Options(headers: _mobileHeaders),
      );
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<void> passwordResetRequest({required String email}) async {
    try {
      await _dio.post(
        Constants.passwordResetRequest,
        data: {'email': email},
        options: Options(headers: _mobileHeaders),
      );
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<String> passwordResetVerify({
    required String email,
    required String code,
  }) async {
    try {
      final response = await _dio.post(
        Constants.passwordResetVerify,
        data: {'email': email, 'code': code},
        options: Options(headers: _mobileHeaders),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final token = data['reset_token'] ?? data['token'] ?? data['uid'];
        if (token != null && token.toString().isNotEmpty) {
          return token.toString();
        }
      }
      throw NetworkException(
        message: TranslationKeys.authInvalidServerResponse.tr(),
      );
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<String> passwordResetConfirm({
    required String resetToken,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        Constants.passwordResetConfirm,
        data: {'reset_token': resetToken, 'new_password': newPassword},
        options: Options(headers: _mobileHeaders),
      );
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final msg = data['detail'] ?? data['message'];
        if (msg is String && msg.isNotEmpty) return msg;
      }
      return TranslationKeys.authPasswordResetDone.tr();
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<void> loginWithApple({
    required String accessToken,
    required String code,
    required String idToken,
  }) async {
    await _storage.token.delete();
    try {
      final response = await _dio.post(
        Constants.appleLogin,
        data: {'access_token': accessToken, 'code': code, 'id_token': idToken},
        options: Options(headers: _mobileHeaders),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _persistTokensFromBody(response.data);
        return;
      }
      throw NetworkException(
        message: TranslationKeys.authAppleLoginFailed.tr(
          namedArgs: {'code': '${response.statusCode ?? ''}'},
        ),
      );
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<void> loginWithGoogle({required String accessToken}) async {
    await _storage.token.delete();
    try {
      final response = await _dio.post(
        Constants.googleLogin,
        data: {'access_token': accessToken},
        options: Options(headers: _mobileHeaders),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _persistTokensFromBody(response.data);
        return;
      }
      throw NetworkException(
        message: TranslationKeys.authGoogleLoginFailed.tr(
          namedArgs: {'code': '${response.statusCode ?? ''}'},
        ),
      );
    } catch (e) {
      _rethrow(e);
    }
  }

  @override
  Future<void> updateRole() async {
    try {
      await _dio.post(
        Constants.updateRole,
        data: {'role': 'Vendor'},
        options: Options(headers: _mobileHeaders),
      );
    } catch (e) {
      _rethrow(e);
    }
  }
}
