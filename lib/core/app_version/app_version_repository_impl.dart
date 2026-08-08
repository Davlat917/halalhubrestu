import 'package:dio/dio.dart';
import 'package:halalhub_restaurant/core/app_version/app_version_repository.dart';
import 'package:halalhub_restaurant/core/app_version/models/app_version_model.dart';
import 'package:halalhub_restaurant/core/constants/constants.dart';
import 'package:halalhub_restaurant/core/network/network_exception.dart'
    show ExceptionHandler, NetworkException, UnexpectedException;
import 'package:injectable/injectable.dart';

@Injectable(as: AppVersionRepository)
class AppVersionRepositoryImpl implements AppVersionRepository {
  AppVersionRepositoryImpl(this._dio);

  final Dio _dio;

  Never _rethrow(Object e) {
    final ex = ExceptionHandler.handleException(e);
    if (ex is NetworkException) throw ex;
    if (ex is UnexpectedException) {
      throw NetworkException(message: ex.message);
    }
    throw NetworkException(message: ex.toString());
  }

  @override
  Future<AppVersionModel> fetchVendorAppVersion() async {
    try {
      final response = await _dio.get(Constants.appVersionVendor);
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw NetworkException(message: 'Invalid app version response');
      }
      return AppVersionModel.fromJson(data);
    } catch (e) {
      _rethrow(e);
    }
  }
}
